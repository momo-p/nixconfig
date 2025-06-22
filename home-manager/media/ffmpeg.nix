{pkgs, ...}: {
  home.packages = with pkgs; [
    (ffmpeg-full.override {withAribcaption = true;})
    libaribcaption
  ];
}
