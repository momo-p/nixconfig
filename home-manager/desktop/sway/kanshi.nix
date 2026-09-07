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
      # also matches with both plugged in, so a switch moves nothing
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
