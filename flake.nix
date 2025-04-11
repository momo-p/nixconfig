{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    stylix.url = "github:danth/stylix";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";

    systems.url = "github:nix-systems/default-linux";
  };

  outputs = {
    self,
    nixpkgs,
    stylix,
    nixvim,
    home-manager,
    auto-cpufreq,
    disko,
    lanzaboote,
    apple-fonts,
    systems,
    ...
  } @ inputs: let
    inherit (self) outputs;

    forEachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = nixpkgs.lib.genAttrs (import systems) (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );
    isFreshInstall = builtins.pathExists ./.install;
    withSecureBootModules = modules: (
      modules
      ++ (nixpkgs.lib.optionals (!isFreshInstall) [
        lanzaboote.nixosModules.lanzaboote
        ./modules/lanzaboote.nix
      ])
    );
  in {
    formatter = forEachSystem (pkgs: pkgs.alejandra);

    nixosConfigurations = {
      nagato = nixpkgs.lib.nixosSystem {
        modules = withSecureBootModules [
          ./hosts/nagato
          disko.nixosModules.disko
        ];
        specialArgs = {
          inherit inputs outputs isFreshInstall;
          username = "momo_p";
        };
      };

      scarlet = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/scarlet
          disko.nixosModules.disko
        ];
        specialArgs = {
          inherit inputs outputs isFreshInstall;
          username = "flandre";
        };
      };

      sajou = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/sajou
          disko.nixosModules.disko
        ];
        specialArgs = {
          inherit inputs outputs isFreshInstall;
          username = "yukimi";
        };
      };
    };
  };
}
