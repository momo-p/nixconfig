{
  config,
  pkgs,
  ...
}: let
  inherit (config.lib.formats.rasi) mkLiteral;
  inherit (config.lib.stylix.colors.withHashtag) base00 base01 base04 base05 base0D base0E;

  # over-fills the inputbar: an exact fit leaves a gap that tiles
  banner = pkgs.runCommand "rofi-banner.png" {} ''
    ${pkgs.imagemagick}/bin/magick ${./momoko.png} -resize 700x240! $out
  '';

  # rofi script modes: no argument asks for the list, an argument is the pick

  clip = pkgs.writeShellScript "rofi-clip" ''
    [ "$#" -eq 0 ] && exec ${pkgs.cliphist}/bin/cliphist list
    printf '%s' "$1" | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
  '';

  power = pkgs.writeShellScript "rofi-power" ''
    if [ "$#" -eq 0 ]; then
      printf '\0no-custom\x1ftrue\n'
      printf '%s\n' lock suspend "log out" reboot "shut down"
      exit 0
    fi
    case "$1" in
      lock) ${pkgs.swaylock-plugin}/bin/swaylock-plugin & ;;
      suspend) ${pkgs.systemd}/bin/systemctl suspend ;;
      "log out") ${pkgs.sway}/bin/swaymsg exit ;;
      reboot) ${pkgs.systemd}/bin/systemctl reboot ;;
      "shut down") ${pkgs.systemd}/bin/systemctl poweroff ;;
    esac
  '';

  wallpaper = pkgs.writeShellScript "rofi-wallpaper" ''
    dir=${./wallpapers}
    if [ "$#" -eq 0 ]; then
      printf '\0no-custom\x1ftrue\n'
      printf '自動\n'
      for f in "$dir"/*; do
        printf '%s\0icon\x1f%s\n' "''${f##*/}" "$f"
      done
      exit 0
    fi
    out=$(${pkgs.sway}/bin/swaymsg -t get_outputs | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .name')
    if [ "$1" = "自動" ]; then
      ${pkgs.wpaperd}/bin/wpaperctl resume-wallpaper "$out"
    else
      ${pkgs.wpaperd}/bin/wpaperctl set-wallpaper "$dir/$1" "$out"
      ${pkgs.wpaperd}/bin/wpaperctl pause-wallpaper "$out"
    fi
  '';

  cursor = import ../cursor/switcher.nix {inherit config pkgs;};

  keys = pkgs.writeShellScript "rofi-keys" ''
    [ "$#" -gt 0 ] && exit 0
    printf '\0no-custom\x1ftrue\n'
    printf '\0markup-rows\x1ftrue\n'
    ${pkgs.gawk}/bin/awk -F'\t' '{
      n = split($1, p, "+");
      mods = "";
      for (i = 1; i < n; i++) mods = mods p[i] "+";
      printf "<span alpha=\"45%%\">%s</span><b>%s</b>  %s  <span alpha=\"45%%\">%s</span>\n", mods, p[n], $2, $3
    }' ${config.xdg.configHome}/sway/keys.tsv
  '';

  rofi-theme = {
    configuration = {
      modi = "drun,run,filebrowser,window,clip:${clip},keysheet:${keys},power:${power},wallpaper:${wallpaper},cursor:${cursor}";
      show-icons = true;
      display-drun = "";
      display-run = "";
      display-filebrowser = "";
      display-window = "";
      display-clip = "";
      display-keysheet = "";
      display-wallpaper = "";
      display-cursor = "";
      display-power = "";
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";
    };

    "*" = {
      font = "SF Pro Display 12";
      background = mkLiteral "${base00}8C";
      background-alt = mkLiteral "${base01}D9";
      foreground = mkLiteral "${base05}";
      selected = mkLiteral "${base0E}";
      selected-foreground = mkLiteral "${base00}";
      active = mkLiteral "${base01}D9";
      active-foreground = mkLiteral "${base0D}";
      urgent = mkLiteral "${base01}D9";
      placeholder-fg = mkLiteral "${base04}";
    };

    window = {
      location = mkLiteral "center";
      anchor = mkLiteral "center";
      fullscreen = false;
      width = mkLiteral "700px";
      x-offset = mkLiteral "0px";
      y-offset = mkLiteral "0px";
      enabled = true;
      border-radius = mkLiteral "24px";
      cursor = mkLiteral "default";
      background-color = mkLiteral "@background";
    };

    mainbox = {
      enabled = true;
      spacing = mkLiteral "0px";
      background-color = mkLiteral "transparent";
      orientation = mkLiteral "vertical";
      children = map mkLiteral ["inputbar" "listbox"];
    };

    listbox = {
      spacing = mkLiteral "12px";
      padding = mkLiteral "12px";
      background-color = mkLiteral "transparent";
      orientation = mkLiteral "vertical";
      children = map mkLiteral ["message" "listview"];
    };

    inputbar = {
      enabled = true;
      spacing = mkLiteral "10px";
      padding = mkLiteral "34px 40px 156px 40px";
      background-color = mkLiteral "transparent";
      background-image = mkLiteral "url('${banner}', width)";
      text-color = mkLiteral "@foreground";
      orientation = mkLiteral "horizontal";
      children = map mkLiteral ["textbox-prompt-colon" "entry" "dummy" "mode-switcher"];
    };

    "textbox-prompt-colon" = {
      enabled = true;
      expand = false;
      str = "";
      font = "SFMono Nerd Font 12";
      padding = mkLiteral "12px 20px 12px 16px";
      border-radius = mkLiteral "100%";
      background-color = mkLiteral "@background-alt";
      text-color = mkLiteral "inherit";
    };

    entry = {
      enabled = true;
      expand = false;
      width = mkLiteral "180px";
      padding = mkLiteral "12px 20px";
      border-radius = mkLiteral "100%";
      background-color = mkLiteral "@background-alt";
      text-color = mkLiteral "inherit";
      cursor = mkLiteral "text";
      placeholder = "Search";
      placeholder-color = mkLiteral "@placeholder-fg";
    };

    dummy = {
      expand = true;
      background-color = mkLiteral "transparent";
    };

    "mode-switcher" = {
      enabled = true;
      spacing = mkLiteral "6px";
      background-color = mkLiteral "transparent";
      text-color = mkLiteral "@foreground";
    };

    button = {
      font = "SFMono Nerd Font 12";
      width = mkLiteral "38px";
      padding = mkLiteral "9px 9px";
      border-radius = mkLiteral "100%";
      background-color = mkLiteral "@background-alt";
      text-color = mkLiteral "inherit";
      cursor = mkLiteral "pointer";
    };

    "button selected" = {
      background-color = mkLiteral "@selected";
      text-color = mkLiteral "@selected-foreground";
    };

    listview = {
      enabled = true;
      columns = 1;
      lines = 7;
      cycle = true;
      dynamic = true;
      scrollbar = false;
      layout = mkLiteral "vertical";
      reverse = false;
      fixed-height = true;
      fixed-columns = true;

      spacing = mkLiteral "4px";
      background-color = mkLiteral "transparent";
      text-color = mkLiteral "@foreground";
      cursor = mkLiteral "default";
    };

    # Element settings
    # 24 window - 12 listbox padding = 12, so the rows sit concentric
    element = {
      enabled = true;
      spacing = mkLiteral "10px";
      padding = mkLiteral "5px 8px";
      border-radius = mkLiteral "12px";
      background-color = mkLiteral "transparent";
      text-color = mkLiteral "@foreground";
      cursor = mkLiteral "pointer";
    };

    "element normal.normal" = {
      background-color = mkLiteral "inherit";
      text-color = mkLiteral "inherit";
    };

    "element normal.urgent" = {
      background-color = mkLiteral "@urgent";
      text-color = mkLiteral "@foreground";
    };

    "element normal.active" = {
      background-color = mkLiteral "@active";
      text-color = mkLiteral "@active-foreground";
    };

    "element selected.normal" = {
      background-color = mkLiteral "@selected";
      text-color = mkLiteral "@selected-foreground";
    };

    "element selected.urgent" = {
      background-color = mkLiteral "@urgent";
      text-color = mkLiteral "@foreground";
    };

    "element selected.active" = {
      background-color = mkLiteral "@urgent";
      text-color = mkLiteral "@foreground";
    };

    element-icon = {
      background-color = mkLiteral "transparent";
      text-color = mkLiteral "inherit";
      size = mkLiteral "32px";
      cursor = mkLiteral "inherit";
    };

    element-text = {
      background-color = mkLiteral "transparent";
      text-color = mkLiteral "inherit";
      cursor = mkLiteral "inherit";
      vertical-align = mkLiteral "0.5";
      horizontal-align = 0;
    };

    message = {
      background-color = mkLiteral "transparent";
    };

    textbox = {
      padding = mkLiteral "12px";
      border-radius = mkLiteral "12px";
      background-color = mkLiteral "@background-alt";
      text-color = mkLiteral "@foreground";
      vertical-align = "1";
      horizontal-align = "0";
    };

    error-message = {
      padding = mkLiteral "12px";
      border-radius = mkLiteral "12px";
      background-color = mkLiteral "@background";
      text-color = mkLiteral "@foreground";
    };
  };
in {
  programs = {
    rofi = {
      enable = true;

      theme = rofi-theme;
    };
  };
}
