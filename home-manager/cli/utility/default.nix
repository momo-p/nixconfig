{pkgs, ...}: {
  imports = [
    ./lf.nix 
    ./compression.nix
  ];

  home.packages = with pkgs; [
    file 

    alejandra
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
