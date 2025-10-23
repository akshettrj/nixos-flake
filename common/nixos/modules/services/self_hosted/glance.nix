{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_glance = config.propheci.services.self_hosted.glance;
  in
    lib.mkIf pro_glance.enable {
      services.glance = {
        enable = true;
        package = pkgs.glance;
        openFirewall = false;
        settings = {
          theme = {
            background-color = "50 1 6";
            primary-color = "24 97 58";
            negative-color = "209 88 54";
          };
          auth = {
          };
          server = {
            host = "127.0.0.1";
            port = pro_glance.port;
            proxied = true;
          };
          pages = pro_glance.pages;
        };
      };

      services.nginx.virtualHosts."${pro_glance.hostname}" = let
        certDir = config.security.acme.certs."${pro_glance.hostname}".directory;
      in {
        forceSSL = true;
        sslCertificate = "${certDir}/cert.pem";
        sslCertificateKey = "${certDir}/key.pem";
        locations."/" = {
          proxyPass = "http://localhost:${toString pro_glance.port}";
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
}
