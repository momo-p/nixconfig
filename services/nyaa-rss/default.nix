{
  virtualisation.oci-containers.containers = {
    container-name = {
      image = "ghcr.io/momo-p/nyaa-rss:latest";
      autoStart = true;
      ports = ["3000:3000"];
    };
  };
}
