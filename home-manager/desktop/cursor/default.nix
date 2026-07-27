{pkgs, ...}: {
  home.pointerCursor = let
    name = "チノ";
  in {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    name = name;
    size = 48;
    package = pkgs.runCommand "moveUp" {} ''
      mkdir -p $out/share/icons/
      ln -s ${./chino} $out/share/icons/${name}
    '';
  };
}
