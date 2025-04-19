{
  virtualisation.oci-containers.containers = {
    jellyfin = {
      image = "jellyfin/jellyfin";
      autoStart = true;
      ports = [
        "8096:8096"
      ];
      volumes = [
        "/mnt/media/jellyfin/config:/config"
        "/mnt/media/jellyfin/cache:/cache"
        "/mnt/media/downloads:/downloads:ro"
        "/mnt/media/media-map:/media:ro"
        "/mnt/media/beets:/music:ro"
      ];
    };
  };
}
