{pkgs, ...}: {
  home.packages = with pkgs; [
    kubernetes-helm
    kubernetes-helmPlugins.helm-diff
    helmfile
  ];
}
