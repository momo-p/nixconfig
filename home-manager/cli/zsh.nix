{
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
  };
}
