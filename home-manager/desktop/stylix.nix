{
  inputs,
  pkgs,
  ...
}: {
  stylix = {
    polarity = "dark";

    # lets the compositor's layer_effects blur show through mako
    opacity.popups = 0.55;

    fonts = {
      monospace = {
        name = "SFMono Nerd Font";
        package = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-mono-nerd;
      };

      sansSerif = {
        name = "SF Pro Display";
        package = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro;
      };

      serif = {
        name = "New York";
        package = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.ny;
      };

      sizes = {
        applications = 12;
        desktop = 12;
        popups = 12;
        terminal = 12;
      };
    };

    targets = {
      sway.useWallpaper = false;
      wpaperd.enable = false;

      rofi.enable = false;
      waybar.enable = false;
      mangohud.enable = false;
      vesktop.enable = false;
    };
  };
}
