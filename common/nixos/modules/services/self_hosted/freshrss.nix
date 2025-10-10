{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_freshrss = config.propheci.services.self_hosted.freshrss;
    pro_user = config.propheci.user;
  in
    lib.mkIf pro_freshrss.enable {
      users.users.freshrss.extraGroups = ["acme" "nginx"];
      users.users."${pro_user.username}".extraGroups = ["freshrss"];

      services.freshrss = {
        enable = true;
        package = pkgs.freshrss;
        extensions = with pkgs.freshrss-extensions; [
          auto-ttl
          reading-time
          reddit-image
          title-wrap
          youtube
        ];
        baseUrl = pro_freshrss.base_url;
        defaultUser = pro_user.username;
        database.type = "sqlite";
        webserver = "nginx";
        virtualHost = pro_freshrss.hostname;
        passwordFile = "/var/lib/default_password";
      };

      services.nginx.virtualHosts."${pro_freshrss.hostname}" = let
        certDir = config.security.acme.certs."${pro_freshrss.hostname}".directory;
      in {
        forceSSL = true;
        sslCertificate = "${certDir}/cert.pem";
        sslCertificateKey = "${certDir}/key.pem";
      };
    };
}
