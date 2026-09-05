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

    defaultSettings = {
      # sway owns the frame, so drop obsidian's own title bar
      app.nativeMenus = true;
      appearance = {
        theme = "obsidian";
        accentColor = config.lib.stylix.colors.withHashtag.base0E;
      };
    };
  };

  home.activation.obsidianVault = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "${config.home.homeDirectory}/${vault}"
  '';
}
