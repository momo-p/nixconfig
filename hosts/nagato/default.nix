{ 
  pkgs,
  disko,
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.home-manager.nixosModules.default
    inputs.stylix.nixosModules.stylix

    ../../modules/1password.nix

    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  networking = {
    hostName = "nagato";
    networkmanager = {
      enable = true;
    };
    firewall = {
      enable = true;
    };
  };

  time.timeZone = "Asia/Ho_Chi_Minh";
  i18n.defaultLocale = "en_US.UTF-8";

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    pam = {
      services = {
        login.enableGnomeKeyring = true;
      };
    };
  };

  users.users.momo_p = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/material-palenight.yaml";
    image = ./wallpaper.jpg;
  };

  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      extraConfig = {
        pipewire = {
          "10-clock-rate" = {
            "context.properties" = {
              "default.clock.allowed-rates" = [44100 48000 88200 96000 176400 192000];
            };
          };
        };
      };
    };
    dbus.enable = true;
    gnome.gnome-keyring.enable = true;
    udisks2.enable = true;
    mullvad-vpn.enable = true;
  };

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    backupFileExtension = "backup";
    users.momo_p = {
      imports = [./home.nix inputs.nixvim.homeManagerModules.nixvim];
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
