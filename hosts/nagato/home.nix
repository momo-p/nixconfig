{pkgs, ...}: {
  imports = [
    ../../home-manager/1password.nix

    ../../home-manager/editor/nixvim
    ../../home-manager/desktop
    ../../home-manager/cli
  ];

  home.username = "momo_p";
  home.homeDirectory = "/home/momo_p";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    anki

    discord
    firefox-devedition-bin

    mpv
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  services = {
    udiskie.enable = true;
  };

  programs.home-manager.enable = true;
}
