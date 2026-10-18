{
  services.keyd = {
    enable = true;
    keyboards.semico = {
      # wired and 2.4G receiver IDs of the SEMICO keyboard
      ids = ["1a2c:7f07" "1a2c:7fff"];
      settings.main = {
        esc = "grave";
        grave = "esc";
      };
    };
  };
}
