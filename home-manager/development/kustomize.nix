{pkgs, ...}: {
  home.packages = with pkgs; [
    kustomize
  ];
}
