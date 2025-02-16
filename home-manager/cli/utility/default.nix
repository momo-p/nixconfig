{pkgs, ...}: {
  imports = [
    ./lf.nix
  ];

  home.packages = with pkgs; [
    file
  ];

  programs = {
    htop.enable = true;
    btop.enable = true;
    fzf.enable = true;
    bat.enable = true;
    eza = {
      enable = true;
      icons = "auto";
    };
    yt-dlp.enable = true;
    starship = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
