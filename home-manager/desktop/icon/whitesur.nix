{pkgs, ...}: {
  gtk.iconTheme = {
    package = pkgs.whitesur-icon-theme;
    name = "WhiteSur-dark";
  };
}
