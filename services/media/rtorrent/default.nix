{
  virtualisation.oci-containers.containers = {
    rtorrent = {
      image = "ghcr.io/momo-p/alpine-rtorrent:0.15.2-r0-v3";
      hostname = "rtorrent";
      user = "1000:1000";
      autoStart = true;
      ports = [
        "50000:50000"
      ];
      volumes = [
        "/mnt/media/downloads:/home/rtorrent/rtorrent/downloads"
        "/mnt/media/rtorrent/.session:/home/rtorrent/rtorrent/.session"
      ];
    };
  };
}
