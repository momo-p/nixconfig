{...}: let
  monitors = import ./monitors.nix;
in {
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.outputs = [
          {
            criteria = monitors.sub;
            position = "0,0";
          }
          {
            criteria = monitors.main;
            position = "1920,0";
            scale = 1.0;
          }
        ];
      }
      # the sub panel is not always awake, so this profile also matches while
      # both are plugged in; giving the main panel the same placement in both
      # means a switch between them moves nothing
      {
        profile.outputs = [
          {
            criteria = monitors.main;
            position = "1920,0";
            scale = 1.0;
          }
        ];
      }
    ];
  };
}
