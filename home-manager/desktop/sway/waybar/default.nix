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
            "custom/arch"
            "sway/workspaces"
          ];
          modules-center = [
            "custom/date"
          ];
          modules-right = [
            "tray"
            "network"
            "pulseaudio"
          ];

          "custom/arch" = {
            format = "  ";
            tooltip = false;
            on-click = "rofi -show drun";
          };

          "sway/workspaces" = {
            format = "{icon}";
            tooltip = false;
            all-outputs = true;
            format-icons = {
              active = "";
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

          network = {
            format-wifi = "<span color='#b4befe'> </span>{essid}";
            format-ethernet = "󰈀";
            format-disconnected = "󰖪";
            tooltip = false;
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
