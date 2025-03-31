{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../home-manager/1password.nix

    ../../home-manager/editor/nixvim
    ../../home-manager/desktop
    ../../home-manager/cli
    ../../home-manager/gaming
  ];

  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    anki

    discord
    vesktop
    firefox-devedition-bin

    mpv
    jellyfin-mpv-shim
  ];

  programs.waybar.settings.mainBar.modules-right = [
    "tray"
    "network"
    "pulseaudio"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  services = {
    udiskie.enable = true;
  };

  programs.home-manager.enable = true;
}
