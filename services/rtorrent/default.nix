{
  virtualisation.oci-containers.containers = {
    rtorrent = {
      image = "ghcr.io/momo-p/alpine-rtorrent:0.15.1-r0";
      autoStart = true;
      ports = [
        "50000:50000"
        "6881:6881"
        "6881:6881/udp"
        "127.0.0.1:16891:16891"
      ];
      volumes = [
        "/mnt/media/downloads:/home/rtorrent/rtorrent/download"
        "/mnt/media/rtorrent/.session:/home/rtorrent/rtorrent/.session"
      ];
    };
  };
}
