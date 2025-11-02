{pkgs, ...}: let
  onePassLinuxPath = "~/.1password/agent.sock";
  onePassDarwinPath = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  onePassPath =
    if (pkgs.stdenv.isLinux)
    then onePassLinuxPath
    else onePassDarwinPath;
in {
  programs.ssh = {
    matchBlocks = {
      "*" = {
        identityAgent = onePassPath;
      };
    };
  };
}
