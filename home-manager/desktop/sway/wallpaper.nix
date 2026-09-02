{
  services.wpaperd = {
    enable = true;

    settings.default = {
      path = "${./wallpapers}";
      duration = "5m";
      sorting = "random";
      mode = "center";
      transition-time = 1000;
    };
  };
}
