{
  virtualisation.oci-containers.containers = {
    nyaa-rss = {
      image = "ghcr.io/momo-p/nyaa-rss:latest";
      autoStart = true;
      ports = ["3000:3000"];
    };
  };
}
