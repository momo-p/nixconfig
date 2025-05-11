{
  virtualisation.oci-containers.containers = {
    deluge = {
      image = "lscr.io/linuxserver/deluge:2.2.0-r0-ls326";
      hostname = "deluge";
      user = "1000:1000";
      autoStart = true;
      ports = [
        "8112:8112"
        "6881:6881"
        "6881:6881/udp"
        "58946:58946"
        "58946:58946/udp"
      ];
      environment = {
        PUID = "1000";
        PGID = "1000";
      };
      volumes = [
        "/mnt/media/downloads:/downloads"
        "/mnt/media/deluge/config:/config"
      ];
    };
  };
}
