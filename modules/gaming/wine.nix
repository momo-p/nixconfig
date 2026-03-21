{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    libxft
    wine
  ];
}
