{pkgs, ...}: {
  programs.steam = {
    enable = true;
    gamescopeSession.enable = false;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
}
