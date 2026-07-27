{pkgs, ...}: {
  programs = {
    vscodium = {
      enable = true;
      package = pkgs.vscodium;
    };
  };
}
