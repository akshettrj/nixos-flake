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
          server = {
            host = "127.0.0.1";
            port = pro_glance.port;
          };
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

