{
  config,
  lib,
  ...
}: let
  vault = "Notes";
in {
  programs.obsidian = {
    enable = true;
    vaults.${vault} = {};
  };

  home.activation.obsidianVault = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "${config.home.homeDirectory}/${vault}"
  '';
}
