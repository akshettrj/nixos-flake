{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_ff = config.propheci.services.self_hosted.firefly_iii;
  in
    lib.mkIf pro_ff.enable {
      services.firefly-iii = {
        enable = true;
        enableNginx = true;
        virtualHost = pro_ff.hostname;
        settings = {
          APP_ENV = "production";
          APP_KEY_FILE = "/etc/secrets/firefly-iii-app-key.txt";
        };
      };

      services.nginx = {
        virtualHosts = {
          "${pro_ff.hostname}" = let
            certDir = config.security.acme.certs."${pro_ff.hostname}".directory;
          in {
            forceSSL = pro_ff.nginx.enable_ssl;
            sslCertificate = "${certDir}/cert.pem";
            sslCertificateKey = "${certDir}/key.pem";
          };
        };
      };
    };
}
