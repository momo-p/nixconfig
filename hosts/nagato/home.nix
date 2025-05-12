{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../home-manager/1password.nix

    ../../home-manager/editor/nixvim
    ../../home-manager/editor/vscodium
    ../../home-manager/desktop
    ../../home-manager/cli
    ../../home-manager/gaming
    ../../home-manager/media
  ];

  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    anki

    discord
    vesktop
    firefox-devedition-bin
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
