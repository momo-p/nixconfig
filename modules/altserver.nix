{pkgs, ...}: let
  anisetteUpstream = 6969;
  anisette = "http://127.0.0.1:6970";

  # the xcode strings sit back to back, so the swap must keep the byte length
  altserver-patched = pkgs.altserver-linux.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.perl];
    postFixup = ''
      chmod u+w $out/bin/alt-server
      perl -0777 -pi -e 's/\Q11.2 (11B41)\E/14.2 (14C18)/g' $out/bin/alt-server
      chmod u-w $out/bin/alt-server
    '';
  });

  alt-server = pkgs.symlinkJoin {
    name = "alt-server-${altserver-patched.version}";
    paths = [altserver-patched];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/alt-server \
        --set-default ALTSERVER_ANISETTE_SERVER ${anisette}
    '';
  };

  # the password lands in alt-server's argv, readable in ps
  sideload = pkgs.writeShellApplication {
    name = "sideload";
    runtimeInputs = [alt-server pkgs.libimobiledevice];
    text = ''
      ipa=''${1:-}
      if [ -z "$ipa" ]; then
        echo "usage: sideload <ipa>" >&2
        exit 1
      fi

      if [ "$(id -u)" -ne 0 ]; then
        echo "sideload needs root" >&2
        exit 1
      fi

      udid=$(idevice_id -l | head -n1)
      if [ -z "$udid" ]; then
        echo "no device on usb" >&2
        exit 1
      fi

      read -rp "apple id: " appleId
      read -rsp "password: " password
      echo

      alt-server -u "$udid" -a "$appleId" -p "$password" "$ipa"
    '';
  };
in {
  environment.systemPackages = [
    alt-server
    sideload
    pkgs.libimobiledevice
    pkgs.ideviceinstaller
  ];

  services.usbmuxd.enable = true;

  systemd.tmpfiles.rules = [
    "d /var/lib/anisette 0700 1000 1000 -"
  ];

  # apple 503s client-info naming <com.apple.dt.Xcode>; the match is literal
  services.nginx = {
    enable = true;
    virtualHosts.anisette = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 6970;
        }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString anisetteUpstream}";
        extraConfig = ''
          proxy_set_header Accept-Encoding "";
          sub_filter_types application/json;
          sub_filter_once on;
          sub_filter "<com.apple.AuthKit/1 (com.apple.dt.Xcode/3594.4.19)>" "<com.apple.AuthKit/1>";
        '';
      };
    };
  };

  virtualisation.oci-containers.containers = {
    anisette = {
      image = "docker.io/dadoum/anisette-v3-server:latest";
      autoStart = true;
      user = "1000:1000";
      ports = [
        "127.0.0.1:6969:6969"
      ];
      volumes = [
        "/var/lib/anisette:/home/Alcoholic/.config/anisette-v3"
      ];
    };
  };
}
