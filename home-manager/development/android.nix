{pkgs, ...}: {
  home.packages = with pkgs; [
    # tiling_wm sets _JAVA_AWT_WM_NONREPARENTING so the IDE windows behave under sway
    (android-studio.override {tiling_wm = true;})
    android-tools
    scrcpy
  ];
}
