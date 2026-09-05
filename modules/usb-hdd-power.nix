{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.hdparm
    pkgs.sdparm
  ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="174c", ATTR{idProduct}=="55aa", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ATTRS{idVendor}=="174c", ATTRS{idProduct}=="55aa", RUN+="${pkgs.hdparm}/bin/hdparm -B 255 -S 0 /dev/%k"
  '';

  powerManagement.resumeCommands = ''
    ${pkgs.hdparm}/bin/hdparm -B 255 -S 0 /dev/disk/by-id/ata-HGST_HUH721010ALE600_JEH4GNWX || true
  '';
}
