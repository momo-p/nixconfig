{pkgs, ...}: let
  statusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = with pkgs; [coreutils jq git];
    text = builtins.readFile ./claude-statusline.sh;
  };
in {
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;

    settings = {
      model = "opus";
      theme = "dark";
      agentPushNotifEnabled = true;
      remoteControlAtStartup = false;

      attribution = {
        commit = "";
        pr = "";
        sessionUrl = false;
      };

      statusLine = {
        type = "command";
        command = "${statusline}/bin/claude-statusline";
        padding = 0;
        refreshInterval = 60;
      };
    };
  };
}
