{
  virtualisation.oci-containers.containers = {
    ftp = {
      image = "stilliard/pure-ftpd:hardened-latest";
      autoStart = true;
      ports = [
        "21:21"
        "30000-30009:30000-30009"
      ];
      volumes = [
        "/home/ssh:/home/shared/ssh/"
      ];
      environment = {
        FTP_USER_NAME = "shared";
        FTP_USER_PASS = "shared";
        FTP_USER_HOME = "/home/shared";
      };
    };
  };
}
