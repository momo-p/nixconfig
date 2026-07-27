{pkgs, ...}: let
  libdisplay-info_0_3 = pkgs.libdisplay-info.overrideAttrs (old: {
    version = "0.3.0";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "emersion";
      repo = "libdisplay-info";
      rev = "0.3.0";
      sha256 = "sha256-nXf2KGovNKvcchlHlzKBkAOeySMJXgxMpbi5z9gLrdc=";
    };
  });
  lact = pkgs.lact.override {
    libdisplay-info = libdisplay-info_0_3;
  };
in {
  environment.systemPackages = [
    lact
  ];
  systemd.packages = [
    lact
  ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
}
