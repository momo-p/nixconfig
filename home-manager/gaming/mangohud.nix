{config, ...}: let
  c = config.lib.stylix.colors;
in {
  programs.mangohud = {
    enable = true;

    settings = {
      # the only surface that survives into a fullscreen game
      round_corners = 12;
      background_alpha = 0.55;
      position = "top-left";

      background_color = c.base00;
      text_color = c.base05;
      gpu_color = c.base0B;
      cpu_color = c.base0D;
      vram_color = c.base0E;
      ram_color = c.base0E;
      engine_color = c.base09;
      frametime_color = c.base0B;

      gpu_temp = true;
      cpu_temp = true;
    };
  };
}
