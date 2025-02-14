{inputs, pkgs, ...}: {
  stylix = {
    polarity = "dark";

    fonts = {
      monospace = {
        name = "SFMonoDisplay Nerd Font";
        package = inputs.apple-fonts.packages.${pkgs.system}.sf-mono-nerd;
      };

      sansSerif = {
        name = "SFProDisplay";
        package = inputs.apple-fonts.packages.${pkgs.system}.sf-pro;
      };

      serif = {
        name = "New York";
        package = inputs.apple-fonts.packages.${pkgs.system}.ny;
      };

      sizes = {
        applications = 12;
        desktop = 12;
        popups = 12;
        terminal = 12;
      };
    };

    targets = {
      rofi.enable = false;
      waybar.enable = false;
    };
  };
}
