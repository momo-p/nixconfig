{
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (config.lib.stylix.colors.withHashtag) base00 base05;

  vencordPkgs = pkgs.extend inputs.vesktop-dnd-inbox.overlays.default;
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
