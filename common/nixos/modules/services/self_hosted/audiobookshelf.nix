{
  config,
  lib,
  ...
}: {
  config = let
    pro_audiobookshelf = config.propheci.services.self_hosted.audiobookshelf;
    pro_nginx = config.propheci.services.nginx;
    pro_user = config.propheci.user;
  in
    lib.mkIf pro_audiobookshelf.enable {
      assertions = [
        {
          assertion =
            if pro_audiobookshelf.nginx.enable
            then pro_nginx.enable
            else true;
          message = "Audiobookshelf's nginx is enabled, but global nginx is not";
        }
      ];

      users.users.audiobookshelf.extraGroups = ["acme"];
      users.users."${pro_user.username}".extraGroups = ["audiobookshelf"];

      services.audiobookshelf = {
        enable = true;
        host = "127.0.0.1";
        port = pro_audiobookshelf.port;
      };

      services.nginx = lib.mkIf pro_audiobookshelf.nginx.enable {
        virtualHosts."${pro_audiobookshelf.nginx.hostname}" = let
          certDir = config.security.acme.certs."${pro_audiobookshelf.nginx.hostname}".directory;
        in {
          forceSSL = pro_audiobookshelf.nginx.enable_ssl;
          sslCertificate = "${certDir}/cert.pem";
          sslCertificateKey = "${certDir}/key.pem";
          locations."/" = {
            proxyPass = "http://localhost:${toString pro_audiobookshelf.port}";
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection 'upgrade';
              proxy_set_header Host $host;
              proxy_cache_bypass $http_upgrade;
            '';
          };
        };
      };

      # propheci.programs.extra_utilities.ffmpeg.enable = lib.mkForce true;
    };
}

