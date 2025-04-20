{
  virtualisation.oci-containers.containers = {
    flood = {
      image = "jesec/flood:latest";
      autoStart = true;
      ports = [
        "5000:3000"
      ];
      volumes = [
        "/mnt/media/downloads:/download"
        "/mnt/media/flood:/root/.local/share/flood"
      ];
    };
  };
}
