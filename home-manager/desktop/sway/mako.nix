{
  config,
  lib,
  ...
}: {
  services.mako = {
    enable = true;

    settings = {
      # stylix owns the colours; this is the one accent placement
      border-color = lib.mkForce config.lib.stylix.colors.withHashtag.base0E;
      border-size = 1;
      border-radius = 18;

      width = 380;
      padding = "13,15";
      margin = "14";
      # 18 - 12 padding, so the icon sits concentric in the card
      icon-border-radius = 6;
      max-icon-size = 36;

      default-timeout = 10000;
      max-history = 50;

      "urgency=critical".default-timeout = 0;

      "mode=do-not-disturb".invisible = 1;
      "mode=do-not-disturb urgency=critical".invisible = 0;
    };
  };
}
