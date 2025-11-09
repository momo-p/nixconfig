{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    pfetch
  ];

  programs.zsh = {
    enable = true;
    history = {
      size = 2000;
      save = 10000;
    };
    enableCompletion = false;
    antidote = {
      enable = true;
      plugins = [
        "reobin/typewritten"
        "zsh-users/zsh-autosuggestions"
      ];
    };
    shellAliases = {
      clear = "clear; pfetch";
    };
    sessionVariables = {
      TYPEWRITTEN_PROMPT_LAYOUT = "singleline_verbose";
    };
    initContent = lib.mkOrder 1500 ''
      clear
    '';
  };
}
