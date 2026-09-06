{
  config,
  lib,
  pkgs,
  ...
}: let
  monitors = import ./monitors.nix;
  inherit (monitors) main sub;

  modifier = "Mod4";
  terminal = "kitty";
  rofi = "${pkgs.rofi}/bin/rofi";
  menu = "${rofi} -show drun";

  # quickshell keys instances by the literal path the shell was started with
  qsIpc = "${pkgs.quickshell}/bin/quickshell ipc -p ${config.xdg.configFile."quickshell".source}";

  dirs = [
    ["Left" "left"]
    ["Right" "right"]
    ["Up" "up"]
    ["Down" "down"]
  ];

  # 1-9 sit on their own digit, 10 on 0; the alt set is the second monitor
  wsKey = n:
    if n == 10
    then "0"
    else toString n;
  wsNum = n: toString n;
  altNum = n: "0${toString n}";

  # bindings and the cheatsheet come from one list, so a new key documents
  # itself and cannot drift out of date
  keyGroups = [
    {
      name = "Apps";
      keys = [
        ["${modifier}+d" "exec ${menu}" "Launcher"]
        ["Ctrl+Alt+t" "exec ${terminal}" "Terminal"]
        ["${modifier}+v" "exec ${rofi} -show clip" "Clipboard history"]
        ["${modifier}+slash" "exec ${rofi} -show keysheet" "This cheatsheet"]
        ["${modifier}+Shift+e" "exec ${rofi} -show power" "Power menu"]
      ];
    }
    {
      name = "Shell";
      keys = [
        ["${modifier}+n" "exec ${qsIpc} call notifications toggle" "Notification history"]
        ["${modifier}+Shift+f" "exec ${qsIpc} call focus toggle" "Focus mode"]
      ];
    }
    {
      name = "Windows";
      keys =
        [
          ["${modifier}+q" "kill" "Close window"]
          ["${modifier}+f" "fullscreen toggle" "Fullscreen"]
          ["${modifier}+s" "floating toggle" "Float"]
          ["${modifier}+t" "sticky toggle" "Sticky"]
          ["${modifier}+b" "splith" "Split horizontal"]
          ["${modifier}+Shift+b" "splitv" "Split vertical"]
          ["${modifier}+Ctrl+r" "mode resize" "Resize mode"]
          ["${modifier}+grave" "scratchpad show" "Scratchpad"]
          ["${modifier}+Shift+grave" "move scratchpad" "Send to scratchpad"]
          ["${modifier}+bracketleft" "focus left" "Focus left"]
          ["${modifier}+bracketright" "focus right" "Focus right"]
        ]
        ++ map (d: ["${modifier}+${builtins.elemAt d 0}" "focus ${builtins.elemAt d 1}" "Focus ${builtins.elemAt d 1}"]) dirs
        ++ map (d: ["${modifier}+Shift+${builtins.elemAt d 0}" "move ${builtins.elemAt d 1}" "Move ${builtins.elemAt d 1}"]) dirs;
    }
    {
      name = "Workspaces";
      keys =
        [
          ["${modifier}+braceleft" "workspace prev_on_output" "Previous workspace"]
          ["${modifier}+braceright" "workspace next_on_output" "Next workspace"]
          ["Alt+Left" "workspace prev_on_output" "Previous workspace"]
          ["Alt+Right" "workspace next_on_output" "Next workspace"]
        ]
        ++ lib.concatMap (n: [
          ["${modifier}+${wsKey n}" "workspace number ${wsNum n}" "Workspace ${wsNum n}"]
          ["${modifier}+Alt+${wsKey n}" "workspace number ${altNum n}" "Workspace ${altNum n}"]
          ["${modifier}+Shift+${wsKey n}" "move container to workspace number ${wsNum n}" "Move to workspace ${wsNum n}"]
          ["${modifier}+Shift+Alt+${wsKey n}" "move container to workspace number ${altNum n}" "Move to workspace ${altNum n}"]
        ]) (lib.range 1 10);
    }
    {
      name = "Screen";
      keys = [
        ["Print" "exec grimshot copy area" "Screenshot area"]
        ["Shift+Print" "exec grimshot copy screen" "Screenshot screen"]
        ["${modifier}+Print" "exec grimshot save area ~/Pictures/shot-$(date +%Y%m%d-%H%M%S).png" "Screenshot area to file"]
        ["${modifier}+w" "exec ${rofi} -show wallpaper" "Wallpaper picker"]
        ["${modifier}+Shift+w" "exec ${pkgs.wpaperd}/bin/wpaperctl next" "Next wallpaper"]
        ["${modifier}+Shift+l" "exec ${pkgs.swaylock-plugin}/bin/swaylock-plugin" "Lock screen"]
        ["${modifier}+r" "reload" "Reload sway"]
      ];
    }
  ];

  binds = lib.concatMap (g:
    map (k: {
      key = builtins.elemAt k 0;
      cmd = builtins.elemAt k 1;
      desc = builtins.elemAt k 2;
      grp = g.name;
    })
    g.keys)
  keyGroups;
in {
  # the cheatsheet is the binding list rendered, never a second copy
  xdg.configFile."sway/keys.tsv".text =
    lib.concatMapStringsSep "\n"
    (b: "${lib.replaceStrings ["Mod4"] ["Mod"] b.key}\t${b.desc}\t${b.grp}")
    binds;

  imports = [
    ./kanshi.nix
    ./wallpaper.nix
    ./xdg.nix
    ./rofi.nix
    ./weather.nix
    ./calendar.nix
    ./quickshell
  ];

  home.packages = with pkgs; [
    tmux

    sway-contrib.grimshot
    slurp

    wl-clipboard

    polkit_gnome

    glib
    viewnior

    mpvpaper
  ];

  programs = {
    swaylock = {
      enable = true;
      package = pkgs.swaylock-plugin;
      settings = {
        command = "${pkgs.mpvpaper}/bin/mpvpaper all -o \"loop --no-resume-playback\" ${./idling.mp4} >/dev/null 2>/dev/null";
        #  clock = true;
        #	indicator = true;
        #	indicator-radius = 75;
        #	indicator-thickness = 7;
        #	ring-color = "292D3E";
        #	line-color = "2B2A3E";
        #	key-h1-color = "414863";
        #	inside-color = "717C8470";
        #	text-color = "FFFFFF";
      };
    };
  };

  services = {
    cliphist.enable = true;
    gnome-keyring = {
      enable = true;
      components = ["secrets"];
    };
    swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 250;
          command = "${pkgs.swaylock-plugin}/bin/swaylock-plugin";
        }
      ];
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    checkConfig = false;
    wrapperFeatures.gtk = true;
    systemd.xdgAutostart = true;

    config = {
      inherit modifier terminal menu;
      defaultWorkspace = "workspace number 1";
      focus = {
        followMouse = false;
        mouseWarping = false;
      };
      startup = [
        {command = "exec ${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";}
        {command = "exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";}
      ];

      bars = [];

      # kanshi owns the external outputs; two writers made it flap
      output.eDP-1.scale = "1.0";
      keybindings = lib.listToAttrs (map (b: lib.nameValuePair b.key b.cmd) binds);

      modes.resize = {
        Left = "resize shrink width 20px";
        Right = "resize grow width 20px";
        Up = "resize shrink height 20px";
        Down = "resize grow height 20px";
        Escape = "mode default";
        Return = "mode default";
      };
    };
    extraConfig = ''
      default_border none
      default_floating_border none

      blur enable
      blur_passes 1
      blur_radius 5

      corner_radius 16
      smart_corner_radius enable

      default_dim_inactive 0.15
      dim_inactive_colors.unfocused #14161FFF

      shadows enable
      shadows_on_csd enable
      shadow_blur_radius 40
      shadow_color #14161F66

      # outer + inner = 14, the same edge the bar margin uses
      gaps outer 4
      gaps inner 10

      # matches WlrLayershell.namespace in the quickshell config
      layer_effects "quickshell-bar" {
        blur enable;
        blur_ignore_transparent enable;
        corner_radius 18;
      }

      layer_effects "quickshell-popup" {
        blur enable;
        blur_ignore_transparent enable;
        shadows enable;
        corner_radius 24;
      }

      layer_effects "notifications" {
        blur enable;
        blur_ignore_transparent enable;
        corner_radius 18;
      }

      layer_effects "rofi" {
        blur enable;
        blur_ignore_transparent enable;
        shadows enable;
        corner_radius 24;
      }

      # gamepad input never resets the wayland idle timer
      for_window [all] inhibit_idle fullscreen

      for_window [app_id="firefox-*" title="^Picture-in-Picture$"] \
        floating enable, move position 16 70, sticky enable

      for_window [class="steam" title="^Friends List$"] floating enable
      for_window [class="steam" title=".* - Chat"] floating enable
      for_window [title="^Steam Keyboard$"] floating enable

      workspace 1 output "${main}"
      workspace 2 output "${main}"
      workspace 3 output "${main}"
      workspace 4 output "${main}"
      workspace 5 output "${main}"
      workspace 6 output "${main}"
      workspace 7 output "${main}"
      workspace 8 output "${main}"
      workspace 9 output "${main}"
      workspace 10 output "${main}"

      workspace 01 output "${sub}"
      workspace 02 output "${sub}"
      workspace 03 output "${sub}"
      workspace 04 output "${sub}"
      workspace 05 output "${sub}"
      workspace 06 output "${sub}"
      workspace 07 output "${sub}"
      workspace 08 output "${sub}"
      workspace 09 output "${sub}"
      workspace 010 output "${sub}"
    '';
  };
}
