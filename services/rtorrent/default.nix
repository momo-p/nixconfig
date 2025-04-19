{
  virtualisation.oci-containers.containers = {
    rtorrent = {
      image = "ghcr.io/momo-p/alpine-rtorrent:0.15.1-r0";
      autoStart = true;
      ports = [
        "5000:3000"
      ];
      volumes = [
        "/mnt/media/downloads:/home/rtorrent/rtorrent/download"
      ];
    };
  };
}
