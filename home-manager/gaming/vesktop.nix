{
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (config.lib.stylix.colors.withHashtag) base00 base05;
in {
  programs.vesktop = {
    enable = true;
    package = inputs.vesktop-dnd-inbox.packages.${pkgs.stdenv.hostPlatform.system}.vesktop;

    settings = {
      customTitleBar = false;
      tray = false;
      splashBackground = base00;
      splashColor = base05;
      splashTheming = true;
    };

    vencord = {
      useSystem = true;

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
