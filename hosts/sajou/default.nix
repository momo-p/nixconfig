{
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.default

    ./hardware-configuration.nix
    ./disk-config.nix
    ./services.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "sajou";
    networkmanager = {
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

  fileSystems = {
    "/mnt/media" = {
      device = "/dev/disk/by-uuid/97dcff17-1c39-43a3-882b-caed9b9eb81d";
      fsType = "ext4";
    };
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

  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
  };

  services = {
    dbus.enable = true;
    udisks2.enable = true;
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

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs username;};
    backupFileExtension = "backup";
    users."${username}" = {
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
