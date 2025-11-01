{
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.outputs = [
          {
            criteria = "Philips Consumer Electronics Company PHL 226V6 UHB1936016087";
            position = "0,0";
          }
          {
            criteria = "AOC 24G2W1G4 ATNM81A001574";
            position = "1920,0";
            mode = "1920x1080@144hz";
          }
        ];
      }
      {
        profile.outputs = [
          {
            criteria = "AOC 24G2W1G4 ATNM81A001574";
            position = "0,0";
            mode = "1920x1080@144hz";
          }
        ];
      }
    ];
  };
}
