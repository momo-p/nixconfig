{pkgs, ...}: let
  # Shows the running Steam game as a Discord activity through arRPC, for games arRPC cannot detect by process name.
  # Games match Discord's detectable list by Steam app ID, then by name or alias.
  steam-presence = pkgs.writeShellApplication {
    name = "steam-presence";
    runtimeInputs = with pkgs; [coreutils curl findutils gnugrep gnused jq procps socat];
    text = ''
      cache=''${XDG_CACHE_HOME:-$HOME/.cache}/steam-presence
      index=$cache/index.json
      socket=''${XDG_RUNTIME_DIR:-/run/user/$UID}/discord-ipc-0
      steam=''${XDG_DATA_HOME:-$HOME/.local/share}/Steam
      mkdir -p "$cache"

      declare -A ids
      last_fetch=0
      current="" started=0 discord=""

      # Discord IPC frame: little-endian opcode and byte length, then the JSON payload.
      frame() {
        local LC_ALL=C
        local n=''${#2}
        printf '%b%s' "$(printf '\\x%02x\\x00\\x00\\x00\\x%02x\\x%02x\\x00\\x00' "$1" $((n & 255)) $((n >> 8 & 255)))" "$2"
      }

      # Rebuilds the index once a day, retrying a failed fetch at most every 10 minutes and keeping the stale index meanwhile.
      refresh_index() {
        [ -n "$(find "$index" -mmin -1440 2>/dev/null)" ] && return
        (($(date +%s) - last_fetch < 600)) && return
        last_fetch=$(date +%s)

        local tmp
        tmp=$(mktemp "$cache/index.XXXXXX")
        if curl -fsS --max-time 60 https://discord.com/api/v9/applications/detectable \
          | jq -c '{
              steam: (map(.id as $id | .third_party_skus // [] | .[] | select(.distributor == "steam") | .id | strings | {key: ., value: $id}) | from_entries),
              name: (map(.id as $id | [.name] + (.aliases // []) | .[] | strings | {key: ascii_downcase, value: $id}) | from_entries)
            }' >"$tmp"; then
          mv "$tmp" "$index"
          ids=()
        else
          rm -f "$tmp"
          echo "could not fetch Discord's game list" >&2
        fi
      }

      steam_name() {
        local lib manifest
        while read -r lib; do
          manifest=$lib/steamapps/appmanifest_$1.acf
          if [ -f "$manifest" ]; then
            sed -n 's/^\s*"name"\s*"\(.*\)"$/\1/p' "$manifest"
            return
          fi
        done < <(sed -n 's/^\s*"path"\s*"\(.*\)"$/\1/p' "$steam/steamapps/libraryfolders.vdf" 2>/dev/null)
      }

      # Sets $discord to the Discord app ID for a Steam app ID, or empty when none matches; results are cached per index.
      resolve() {
        if [ -z "''${ids[$1]+set}" ]; then
          refresh_index
          [ -f "$index" ] || { discord=""; return; }
          local name
          name=$(steam_name "$1")
          ids[$1]=$(jq -r --arg app "$1" --arg name "$name" '.steam[$app] // .name[$name | ascii_downcase] // empty' "$index")
          echo "steam app $1 ($name): discord app ''${ids[$1]:-none}"
        fi
        discord=''${ids[$1]}
      }

      connected() {
        [ -n "''${RPC_PID:-}" ] && kill -0 "$RPC_PID" 2>/dev/null
      }

      # arRPC clears the activity when the socket closes.
      disconnect() {
        if [ -n "''${RPC_PID:-}" ]; then
          kill "$RPC_PID" 2>/dev/null || true
          wait "$RPC_PID" 2>/dev/null || true
        fi
      }

      connect() {
        coproc RPC { socat - "UNIX-CONNECT:$socket" >/dev/null 2>&1; }
        {
          frame 0 "$(jq -nc --arg id "$1" '{v: 1, client_id: $id}')"
          frame 1 "$(jq -nc --argjson pid "$2" --argjson start "$started" \
            '{cmd: "SET_ACTIVITY", nonce: "1", args: {pid: $pid, activity: {timestamps: {start: $start}}}}')"
        } 1>&"''${RPC[1]:-}" 2>/dev/null || true
      }

      trap disconnect EXIT
      trap "" PIPE

      while true; do
        game=$(pgrep -af 'SteamLaunch AppId=[0-9]+' | head -n1 || true)
        appid=$(grep -oP 'AppId=\K[0-9]+' <<<"$game" || true)

        if [ "$appid" != "$current" ]; then
          disconnect
          current=$appid
          started=$(date +%s)
        fi

        if [ -n "$appid" ] && [ -S "$socket" ] && ! connected; then
          resolve "$appid"
          [ -n "$discord" ] && connect "$discord" "''${game%% *}"
        fi

        sleep 5
      done
    '';
  };
in {
  systemd.user.services.steam-presence = {
    Unit = {
      Description = "Discord presence for Steam games";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${steam-presence}/bin/steam-presence";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
