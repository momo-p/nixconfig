{
  pkgs,
  lib,
  inputs,
  ...
}: let
  statusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = with pkgs; [coreutils jq git];
    text = builtins.readFile ./claude-statusline.sh;
  };
  styles = inputs.agent-styles;

  impeccable-flutter = import ./impeccable-flutter.nix {
    inherit pkgs;
    src = inputs.impeccable-flutter;
  };
in {
  home.packages = [pkgs.gitleaks impeccable-flutter];

  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code.override {
      manifest = lib.importJSON ./claude-manifest.zst.json;
    };

    context = builtins.readFile "${styles}/AGENTS.md";
    hooksDir = "${styles}/hooks";
    skills = {
      humanizer = "${styles}/skills/humanizer";
      impeccable-flutter = "${inputs.impeccable-flutter}/skills/impeccable-flutter";
    };

    settings = lib.recursiveUpdate (builtins.fromJSON (builtins.readFile "${styles}/settings.json")) {
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
