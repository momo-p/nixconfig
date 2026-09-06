{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  # editing a secret needs these on hand
  environment.systemPackages = [pkgs.sops pkgs.age];

  sops = {
    defaultSopsFile = ../secrets/nagato.yaml;

    # no sshd on this host, so there is no ssh host key to reuse as an
    # identity; this one is generated once and lives outside the store
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };
}
