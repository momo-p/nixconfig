{pkgs, ...}: {
  programs = {
    nixvim = {
      enable = true;
      defaultEditor = true;

      opts = {
        number = true;
        relativenumber = true;
        shiftwidth = 4;
        softtabstop = 4;
        expandtab = true;
        smartindent = true;
      };
    };
  };
}
