{
  config,
  pkgs,
  ...
}: {
  home.packages = [
    (import ./cover-package.nix {
      inherit pkgs;
      cacheHome = config.xdg.cacheHome;
    })
  ];
}
