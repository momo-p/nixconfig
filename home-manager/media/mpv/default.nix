{
  lib,
  pkgs,
  ...
}: let
  jellyfin-mpv-shim = pkgs.callPackage ./jellyfin-mpv-shim.nix {inherit lib pkgs;};
in {
  home.packages = [
    pkgs.mpv
    jellyfin-mpv-shim
  ];
}
