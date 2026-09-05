{config, ...}: let
  inherit (config.lib.stylix.colors.withHashtag) base00 base05;
in {
  programs.vesktop = {
    enable = true;

    settings = {
      customTitleBar = false;
      tray = false;
      splashBackground = base00;
      splashColor = base05;
      splashTheming = true;
    };

    vencord = {
      settings = {
        plugins = {
          ReadAllNotificationsButton.enabled = true;
          AnonymiseFileNames.enabled = true;
          ImageFilename.enabled = true;
          ExpressionCloner.enabled = true;
          SilentTyping.enabled = true;
        };
      };
    };
  };
}
