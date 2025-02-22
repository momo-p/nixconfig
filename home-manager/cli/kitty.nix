{
  lib,
  pkgs,
  ...
}: {
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = lib.mkForce 0.92;

      window_logo_path = "${./nina.png}";
      window_logo_scale = 20;
      window_logo_alpha = 0.15;
    };
  };
}
