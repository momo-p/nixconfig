{pkgs, ...}: {
  home.packages = with pkgs; [
    pavucontrol
    python314
  ];

  programs = {
    waybar = {
      enable = true;
      style = ./style.css;
      settings = {
        mainBar = {
          layer = "top";
          mode = "dock";
          modules-left = [
            "custom/launcher"
            "sway/workspaces"
          ];
          modules-center = [
            "custom/date"
          ];

          "custom/launcher" = {
            format = "  ";
            tooltip = false;
            on-click = "rofi -show drun";
          };

          "sway/workspaces" = {
            format = "{icon}";
            tooltip = false;
            all-outputs = true;
            format-icons = {
              focused = "";
              default = "";
            };
          };

          "custom/date" = {
            exec = "python3 -u ${./scripts/date.py}";
            interval = 10;
            format = "{}";
            tooltip = false;
          };

          tray = {
            spacing = 10;
          };

          battery = {
            states = {
              warning = 25;
              critical = 15;
            };
            format = "{icon}";
            format-icons = ["" "" "" "" ""];
            tooltip-format = "{capacity}% ({timeTo})";
          };

          network = {
            format-wifi = "";
            format-ethernet = "󰈀";
            format-disconnected = "󰖪";
            tooltip-format = "{ifname}";
            tooltip-format-wifi = "{essid} ({frequency}GHz)";
            tooltip-format-disconnected = "Disconnected";
          };

          pulseaudio = {
            format = "{icon}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = "🔇";
            format-muted = "🔇";
            format-source = "  {volume}%";
            format-source-muted = "";
            tooltip-format = "{volume}%";
            format-icons = {
              "hands-free" = "";
              "headset" = "";
              "phone" = "";
              "portable" = "";
              "car" = "";
              default = [
                "🔈"
                "🔉"
                "🔊"
              ];
            };
            on-click = "pavucontrol";
          };
        };
      };
    };
  };
}
