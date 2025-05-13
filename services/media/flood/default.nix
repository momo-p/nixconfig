{
  virtualisation.oci-containers.containers = {
    flood = {
      image = "jesec/flood:latest";
      user = "1000:1000";
      autoStart = true;
      ports = [
        "5000:3000"
      ];
      volumes = [
        "/mnt/media/downloads:/home/rtorrent/rtorrent/downloads"
        "/mnt/media/downloads:/downloads"
        "/mnt/media/flood:/home/node/.local/share/flood"
      ];
    };
  };
}
