{config, ...}: let
  inherit (config.lib.formats.rasi) mkLiteral;
  inherit (config.lib.stylix.colors.withHashtag) base00 base01 base04 base05 base0D base0E;

  rofi-theme = {
    configuration = {
      modi = "drun,run,filebrowser,window";
      show-icons = true;
      display-drun = "";
      display-run = "";
      display-filebrowser = "";
      display-window = "";
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";
    };

    # Global properties
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

    # Main window settings
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

    # Main box settings
    mainbox = {
      enabled = true;
      spacing = mkLiteral "0px";
      background-color = mkLiteral "transparent";
      orientation = mkLiteral "vertical";
      children = map mkLiteral ["inputbar" "listbox"];
    };

    # Listbox settings
    listbox = {
      spacing = mkLiteral "12px";
      padding = mkLiteral "12px";
      background-color = mkLiteral "transparent";
      orientation = mkLiteral "vertical";
      children = map mkLiteral ["message" "listview"];
    };

    # Inputbar settings
    inputbar = {
      enabled = true;
      spacing = mkLiteral "10px";
      padding = mkLiteral "34px 40px";
      background-color = mkLiteral "transparent";
      background-image = mkLiteral "url('${./momoko.png}', width)";
      text-color = mkLiteral "@foreground";
      orientation = mkLiteral "horizontal";
      children = map mkLiteral ["textbox-prompt-colon" "entry" "dummy" "mode-switcher"];
    };

    # Textbox prompt colon settings
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

    # Entry settings
    entry = {
      enabled = true;
      expand = false;
      width = mkLiteral "250px";
      padding = mkLiteral "12px 20px";
      border-radius = mkLiteral "100%";
      background-color = mkLiteral "@background-alt";
      text-color = mkLiteral "inherit";
      cursor = mkLiteral "text";
      placeholder = "Search";
      placeholder-color = mkLiteral "@placeholder-fg";
    };

    # Dummy settings
    dummy = {
      expand = true;
      background-color = mkLiteral "transparent";
    };

    # Mode switcher settings
    "mode-switcher" = {
      enabled = true;
      spacing = mkLiteral "10px";
      background-color = mkLiteral "transparent";
      text-color = mkLiteral "@foreground";
    };

    # Button settings
    button = {
      font = "SFMono Nerd Font 12";
      width = mkLiteral "45px";
      padding = mkLiteral "12px 16px 12px 12px";
      border-radius = mkLiteral "100%";
      background-color = mkLiteral "@background-alt";
      text-color = mkLiteral "inherit";
      cursor = mkLiteral "pointer";
    };

    # Button selected settings
    "button selected" = {
      background-color = mkLiteral "@selected";
      text-color = mkLiteral "@selected-foreground";
    };

    # Listview settings
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

    # Message settings
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
