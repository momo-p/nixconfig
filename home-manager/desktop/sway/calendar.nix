{
  config,
  pkgs,
  ...
}: let
  cache = "${config.xdg.cacheHome}/agenda.json";

  pyEnv = pkgs.python3.withPackages (p: [p.icalendar p.recurring-ical-events]);

  sync = pkgs.writeShellScript "agenda-sync" ''
    AGENDA_CACHE=${cache} exec ${pyEnv}/bin/python3 ${./agenda-sync.py}
  '';

  # a google ical url carries its token, so the feed list is a credential
  add = pkgs.writeShellScriptBin "calendar-add" ''
    set -eu
    repo=''${NIXCONFIG:-$HOME/nixconfig}
    file=$repo/secrets/nagato.yaml
    [ -f "$file" ] || { echo "no $file" >&2; exit 1; }

    printf 'name (used as the colour key): '; read -r name
    printf 'ical url: '; read -r url

    sops=${pkgs.sops}/bin/sops
    current=$("$sops" -d --extract '["ical"]' "$file" 2>/dev/null || true)
    [ "$current" = "REPLACE_ME" ] && current=""

    updated=$(printf '%s\n%s %s\n' "$current" "$name" "$url" | ${pkgs.gnused}/bin/sed '/^$/d')
    "$sops" --set "[\"ical\"] $(printf '%s' "$updated" | ${pkgs.jq}/bin/jq -Rs .)" "$file"

    echo "added $name. commit secrets/nagato.yaml, rebuild, then:"
    echo "  systemctl --user start agenda-sync"
  '';
in {
  home.packages = [add];

  systemd.user.services.agenda-sync = {
    Unit.Description = "expand subscribed calendars";
    Service = {
      Type = "oneshot";
      ExecStart = "${sync}";
    };
  };

  systemd.user.timers.agenda-sync = {
    Unit.Description = "refresh subscribed calendars";
    Timer = {
      OnStartupSec = "40s";
      OnUnitActiveSec = "15m";
    };
    Install.WantedBy = ["timers.target"];
  };
}
