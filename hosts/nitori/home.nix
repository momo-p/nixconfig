{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../home-manager/editor/nixvim
    ../../home-manager/cli
    ../../home-manager/development/helm.nix
  ];

  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    ffmpeg
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  services = {
    udiskie.enable = true;
  };

  programs.home-manager.enable = true;
}
