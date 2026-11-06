{
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (config.lib.stylix.colors.withHashtag) base00 base05;

  # nixpkgs ships Vencord 1.15.13, which crashes on the current Discord client and leaves the window blank.
  vencordPkgs =
    (pkgs.extend (final: prev: {
      vencord = prev.vencord.overrideAttrs (finalAttrs: old: {
        version = "1.15.16";
        src = old.src.override {
          tag = "v${finalAttrs.version}";
          hash = "sha256-aUJubLJpyLAZWiOezqFxPY6oVPgWVPQpajFqrJvrO9U=";
        };
        # Upstream now pins React 19 types itself, so the nixpkgs lockfile fixups no longer apply.
        patches = [];
        postPatch = "";
        pnpmDeps = old.pnpmDeps.overrideAttrs {
          outputHash = "sha256-HS8uZNepvDefjrsG3buVLFCVv7sHvazcwdpcT3EQ/78=";
        };
      });
    }))
    .extend
    inputs.vesktop-dnd-inbox.overlays.default;
in {
  programs.vesktop = {
    enable = true;
    package = vencordPkgs.vesktop;

    settings = {
      arRPC = true;
      customTitleBar = false;
      tray = false;
      splashBackground = base00;
      splashColor = base05;
      splashTheming = true;
    };

    vencord = {
      useSystem = true;
      mutableSettings = true;

      settings = {
        plugins = {
          ReadAllNotificationsButton.enabled = true;
          AnonymiseFileNames.enabled = true;
          ImageFilename.enabled = true;
          ExpressionCloner.enabled = true;
          SilentTyping.enabled = true;
          DndInbox.enabled = true;
        };
      };
    };
  };
}
