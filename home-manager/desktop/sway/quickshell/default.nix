{
  config,
  inputs,
  pkgs,
  ...
}: let
  coverFetch = import ../cover-package.nix {
    inherit pkgs;
    cacheHome = config.xdg.cacheHome;
  };
  inherit (config.lib.stylix.colors.withHashtag) base00 base01 base03 base04 base05 base08 base0A base0B base0D base0E;

  # YANIS uses fill:currentColor, so a state is just a recoloured copy
  yanisIcon = path: color:
    pkgs.runCommand "qs-yanis-${baseNameOf path}" {} ''
      ${pkgs.gnused}/bin/sed 's|currentColor|${color}|g' ${inputs.yanis}/${path} > $out
    '';

  trayEntry = name: path: ''"${name}": "file://${yanisIcon path base05}"'';

  # the lock only changes on a flake update, so the timestamps can be baked
  # in and compared against the clock at runtime
  inputTimes = let
    lock = builtins.fromJSON (builtins.readFile ../../../../flake.lock);
    nodes = builtins.attrValues (builtins.removeAttrs lock.nodes ["root"]);
  in
    builtins.filter (t: t != null) (map (n: n.locked.lastModified or null) nodes);

  # fcitx emits no dbus signal on switch, so poll in one long-lived process
  # and only write a line when the value actually changes
  fcitxWatch = pkgs.writeShellScript "fcitx-watch" ''
    prev=""
    while :; do
      cur=$(${pkgs.fcitx5}/bin/fcitx5-remote -n 2>/dev/null || true)
      if [ "$cur" != "$prev" ]; then
        printf '%s\n' "$cur"
        prev=$cur
      fi
      ${pkgs.coreutils}/bin/sleep 1
    done
  '';

  theme = pkgs.writeText "Theme.qml" ''
    pragma Singleton
    import QtQuick

    QtObject {
        readonly property color base: "${base00}"
        readonly property color surface: "${base01}"
        readonly property color overlay: "${base03}"
        readonly property color subtext: "${base04}"
        readonly property color text: "${base05}"
        readonly property color red: "${base08}"
        readonly property color yellow: "${base0A}"
        readonly property color green: "${base0B}"
        readonly property color blue: "${base0D}"
        readonly property color accent: "${base0E}"

        readonly property int barHeight: 50
        readonly property int pillHeight: 34
        readonly property int edge: 14
        readonly property int iconSize: 18
        readonly property int cardWidth: 380

        readonly property var inputTimes: [${builtins.concatStringsSep ", " (map toString inputTimes)}]

        // connector names are not stable across restarts, so the shell picks
        // its output by the same identity kanshi and sway match on
        readonly property string mainMonitor: "${(import ../monitors.nix).main}"

        function pill(alpha) {
            return Qt.rgba(base.r, base.g, base.b, alpha);
        }
        function hairline(alpha) {
            return Qt.rgba(text.r, text.g, text.b, alpha);
        }
        function fade(c, alpha) {
            return Qt.rgba(c.r, c.g, c.b, alpha);
        }

        // consecutive true values become one {at, len}, which is what draws a
        // wet stretch as a single piece rather than blocks that happen to touch
        function runs(flags) {
            const out = [];
            let i = 0;
            while (i < flags.length) {
                if (!flags[i]) {
                    i++;
                    continue;
                }
                let n = 0;
                while (i + n < flags.length && flags[i + n])
                    n++;
                out.push({at: i, len: n});
                i += n;
            }
            return out;
        }

        readonly property string launcher: "${pkgs.rofi}/bin/rofi -show drun"
        readonly property string pavucontrol: "${pkgs.pavucontrol}/bin/pavucontrol"
        readonly property string fcitxWatch: "${fcitxWatch}"
        readonly property string fcitxRemote: "${pkgs.fcitx5}/bin/fcitx5-remote"
        readonly property string mullvad: "${pkgs.mullvad}/bin/mullvad"
        readonly property string tailscale: "${pkgs.tailscale}/bin/tailscale"
        readonly property string stat: "${pkgs.coreutils}/bin/stat"
        readonly property string coverFetch: "${coverFetch}/bin/cover-fetch"
        readonly property string wpaperctl: "${pkgs.wpaperd}/bin/wpaperctl"
        readonly property string weatherCache: "${config.xdg.cacheHome}/weather.json"
        readonly property string agendaCache: "${config.xdg.cacheHome}/agenda.json"
        readonly property string notifCache: "${config.xdg.cacheHome}/notifications.json"

        readonly property var wallpaperCredits: (${builtins.toJSON (import ../wallpaper-credits.nix)})

        // mirrors the group in home-manager/desktop/fcitx5.nix
        readonly property var inputMethods: ["keyboard-us", "anthy", "bamboo"]

        // pixmap tray icons cannot be themed, so replace them by id instead
        readonly property var trayIcons: ({
            ${builtins.concatStringsSep ",\n            " [
      (trayEntry "steam" "status/scalable/steam_tray_mono.svg")
      (trayEntry "1password" "status/scalable/1password-panel.svg")
      (trayEntry "vesktop" "apps/scalable/dev.vencord.Vesktop.svg")
      (trayEntry "discord" "status/scalable/discord-tray-connected.svg")
      (trayEntry "obsidian" "apps/scalable/Obsidian.svg")
    ]}
        })

        // superseded by a dedicated module, so keep it out of the tray
        readonly property var trayHiddenKeys: ["fcitx"]

        function trayHidden(id, title) {
            const k = ((id || "") + " " + (title || "")).toLowerCase();
            for (const n of trayHiddenKeys)
                if (k.indexOf(n) !== -1)
                    return true;
            return false;
        }

        function trayIconFor(id, title, fallback) {
            const k = ((id || "") + " " + (title || "")).toLowerCase();
            for (const name in trayIcons)
                if (k.indexOf(name) !== -1)
                    return trayIcons[name];
            return fallback;
        }

        readonly property string iconLauncher: "file://${yanisIcon "apps/scalable/nix-snowflake.svg" base0E}"
        readonly property string iconMicOff: "file://${yanisIcon "status/scalable/audio-input-microphone-none-panel.svg" base08}"
        readonly property string iconVol: "file://${yanisIcon "status/scalable/audio-volume-high-panel.svg" base05}"
        readonly property string iconVolOff: "file://${yanisIcon "status/scalable/audio-volume-muted-panel.svg" base08}"
        readonly property string iconWired: "file://${yanisIcon "status/scalable/network-wired-activated-symbolic.svg" base05}"
        readonly property string iconWifi: "file://${yanisIcon "status/scalable/network-wireless-connected-100-symbolic.svg" base05}"
        readonly property string iconNetOff: "file://${yanisIcon "status/scalable/network-offline.svg" base08}"
        readonly property string iconBattery: "file://${yanisIcon "status/scalable/battery-100-symbolic.svg" base05}"
        readonly property string iconBatteryLow: "file://${yanisIcon "status/scalable/battery-020-symbolic.svg" base0A}"
        readonly property string iconBatteryCrit: "file://${yanisIcon "status/scalable/battery-020-symbolic.svg" base08}"
        readonly property string iconVpn: "file://${yanisIcon "status/scalable/nm-vpn-standalone-lock.svg" base05}"
        readonly property string iconVpnWait: "file://${yanisIcon "status/scalable/nm-vpn-standalone-lock.svg" base0A}"
        readonly property string iconVpnBlocked: "file://${yanisIcon "status/scalable/nm-vpn-standalone-lock.svg" base08}"
        readonly property string iconDnd: "file://${yanisIcon "status/scalable/notifications-disabled-symbolic.svg" base0E}"
        readonly property string iconPrev: "file://${yanisIcon "actions/16/media-skip-backward.svg" base05}"
        readonly property string iconNext: "file://${yanisIcon "actions/16/media-skip-forward.svg" base05}"
        readonly property string iconPlay: "file://${yanisIcon "actions/16/media-playback-start.svg" base05}"
        readonly property string iconPause: "file://${yanisIcon "actions/16/media-playback-pause.svg" base05}"
    }
  '';

  # qmldir is generated so adding a component needs no edit here
  configDir = pkgs.runCommand "quickshell-config" {} ''
    mkdir -p $out
    cp ${./qml}/*.qml $out/
    cp ${theme} $out/Theme.qml
    for f in $out/*.qml; do
      n=$(basename "$f" .qml)
      [ "$n" = shell ] && continue
      if head -1 "$f" | grep -q '^pragma Singleton'; then
        echo "singleton $n 1.0 $n.qml"
      else
        echo "$n 1.0 $n.qml"
      fi
    done > $out/qmldir
  '';
in {
  home.packages = [pkgs.quickshell pkgs.pavucontrol];

  # also on disk so `qs` works by hand
  xdg.configFile."quickshell".source = configDir;

  # a unit rather than a sway exec, so it restarts on failure and on rebuild.
  # the config path is baked in, which is what makes the unit change when the
  # qml changes, so home-manager restarts it.
  systemd.user.services.quickshell = {
    Unit = {
      Description = "quickshell desktop shell";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell -p ${configDir}";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
