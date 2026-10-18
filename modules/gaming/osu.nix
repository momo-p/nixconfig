{
  pkgs,
  inputs,
  ...
}: let
  gaming = inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system};
in {
  nix.settings = {
    substituters = ["https://nix-gaming.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };

  environment.systemPackages = [
    gaming.osu-lazer-bin
    gaming.osu-stable
  ];
}
