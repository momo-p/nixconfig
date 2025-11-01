{pkgs, ...}: let
  mainMonitor = "AOC 24G2W1G4 ATNM81A001574";
  subMonitor = "Philips Consumer Electronics Company PHL 226V6 UHB1936016087";
in {
  imports = [
    ./kanshi.nix
    ./xdg.nix
    ./rofi.nix
    ./mako.nix
    ./waybar
  ];

  home.packages = with pkgs; [
    tmux

    sway-contrib.grimshot
    slurp

    wl-clipboard

    polkit_gnome

    glib
    viewnior
  ];

  programs = {
    swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      #      settings = {
      #        clock = true;
      #	indicator = true;
      #	indicator-radius = 75;
      #	indicator-thickness = 7;
      #	ring-color = "292D3E";
      #	line-color = "2B2A3E";
      #	key-h1-color = "414863";
      #	inside-color = "717C8470";
      #	text-color = "FFFFFF";
      #      };
    };
  };

  services = {
    cliphist.enable = true;
    gnome-keyring = {
      enable = true;
      components = ["secrets"];
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    checkConfig = false;
    wrapperFeatures.gtk = true;
    systemd.xdgAutostart = true;

    config = rec {
      modifier = "Mod4";
      terminal = "kitty";
      defaultWorkspace = "workspace number 1";
      focus = {
        followMouse = false;
        mouseWarping = false;
      };
      startup = [
        {command = "exec ${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";}
        {command = "exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";}
      ];

      menu = "${pkgs.rofi}/bin/rofi -show drun";

      bars = [{command = "${pkgs.waybar}/bin/waybar";}];

      output = {
        "AOC 24G2W1G4 ATNM81A001574" = {
          mode = "1920x1080@144Hz";
          scale = "1.0";
        };
        eDP-1 = {
          scale = "1.0";
        };
      };
      keybindings = {
        "Print" = "exec grimshot copy area";
        "Shift+Print" = "exec grimshot copy screen";

        "${modifier}+d" = "exec ${menu}";
        "Ctrl+Alt+t" = "exec ${terminal}";

        "${modifier}+r" = "reload";
        "${modifier}+q" = "kill";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+s" = "floating toggle";
        "${modifier}+t" = "sticky toggle";
        "${modifier}+Shift+e" = "exec swaymsg exit";

        # focus
        "${modifier}+bracketleft" = "focus left";
        "${modifier}+bracketright" = "focus right";
        "${modifier}+Left" = "focus left";
        "${modifier}+Right" = "focus right";
        "${modifier}+Up" = "focus up";
        "${modifier}+Down" = "focus down";

        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Right" = "move right";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Down" = "move down";

        # workspace
        "${modifier}+braceleft" = "workspace prev_on_output";
        "${modifier}+braceright" = "workspace next_on_output";
        "Alt+Left" = "workspace prev_on_output";
        "Alt+Right" = "workspace next_on_output";

        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";

        "${modifier}+Alt+1" = "workspace number 01";
        "${modifier}+Alt+2" = "workspace number 02";
        "${modifier}+Alt+3" = "workspace number 03";
        "${modifier}+Alt+4" = "workspace number 04";
        "${modifier}+Alt+5" = "workspace number 05";
        "${modifier}+Alt+6" = "workspace number 06";
        "${modifier}+Alt+7" = "workspace number 07";
        "${modifier}+Alt+8" = "workspace number 08";
        "${modifier}+Alt+9" = "workspace number 09";
        "${modifier}+Alt+0" = "workspace number 010";

        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";

        "${modifier}+Shift+Alt+1" = "move container to workspace number 01";
        "${modifier}+Shift+Alt+2" = "move container to workspace number 02";
        "${modifier}+Shift+Alt+3" = "move container to workspace number 03";
        "${modifier}+Shift+Alt+4" = "move container to workspace number 04";
        "${modifier}+Shift+Alt+5" = "move container to workspace number 05";
        "${modifier}+Shift+Alt+6" = "move container to workspace number 06";
        "${modifier}+Shift+Alt+7" = "move container to workspace number 07";
        "${modifier}+Shift+Alt+8" = "move container to workspace number 08";
        "${modifier}+Shift+Alt+9" = "move container to workspace number 09";
        "${modifier}+Shift+Alt+0" = "move container to workspace number 010";
      };
    };
    extraConfig = ''
      default_border none
      default_floating_border none

      blur enable
      blur_passes 1
      blur_radius 5

      corner_radius 10

      gaps outer 6
      gaps inner 10

      for_window [app_id="firefox-*" title="^Picture-in-Picture$"] \
        floating enable, move position 16 70, sticky enable

      workspace 1 output "${mainMonitor}"
      workspace 2 output "${mainMonitor}"
      workspace 3 output "${mainMonitor}"
      workspace 4 output "${mainMonitor}"
      workspace 5 output "${mainMonitor}"
      workspace 6 output "${mainMonitor}"
      workspace 7 output "${mainMonitor}"
      workspace 8 output "${mainMonitor}"
      workspace 9 output "${mainMonitor}"
      workspace 10 output "${mainMonitor}"

      workspace 01 output "${subMonitor}"
      workspace 02 output "${subMonitor}"
      workspace 03 output "${subMonitor}"
      workspace 04 output "${subMonitor}"
      workspace 05 output "${subMonitor}"
      workspace 06 output "${subMonitor}"
      workspace 07 output "${subMonitor}"
      workspace 08 output "${subMonitor}"
      workspace 09 output "${subMonitor}"
      workspace 010 output "${subMonitor}"
    '';
  };
}
