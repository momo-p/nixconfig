{pkgs, ...}: {
  imports = [
    ./plugins

    ./keymaps.nix
  ];

  programs = {
    nixvim = {
      enable = true;
      defaultEditor = true;

      opts = {
        number = true;
        shiftwidth = 4;
        softtabstop = 4;
        expandtab = true;
        smartindent = true;
      };
    };
  };
}
