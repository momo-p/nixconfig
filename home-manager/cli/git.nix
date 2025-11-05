{
  lib,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "momo-p";
        email = "momo-p@chong-arisu.id.vn";
      };
    };
    signing = {
      signByDefault = true;
      format = "ssh";
      signer = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHXeyWQOrmK7iqaikskN+iahSHa6wwKlEX4By0xLBr8d";
    };
  };
}
