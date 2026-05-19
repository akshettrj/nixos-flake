{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.services.self_hosted.firefly_iii = {
        enable = lib.mkEnableOption "Firefly III";

        hostname = lib.mkOption {
            type = lib.types.str;
            description = "Public hostname for Firefly III.";
        };

        nginx.enable_ssl = lib.mkOption {
            type = lib.types.bool;
            description = "Force SSL for the Firefly III Nginx virtual host.";
        };
    };

    config =
        let
            biryani_ff = config.biryani.services.self_hosted.firefly_iii;
        in
        lib.mkIf biryani_ff.enable {
            services.firefly-iii = {
                enable = true;
                enableNginx = true;
                virtualHost = biryani_ff.hostname;
                settings = {
                    APP_ENV = "production";
                    APP_KEY_FILE = "/etc/secrets/firefly-iii-app-key.txt";
                };
            };

            services.nginx = {
                virtualHosts = {
                    "${biryani_ff.hostname}" =
                        let
                            certDir = config.security.acme.certs."${biryani_ff.hostname}".directory;
                        in
                        {
                            forceSSL = biryani_ff.nginx.enable_ssl;
                            sslCertificate = "${certDir}/cert.pem";
                            sslCertificateKey = "${certDir}/key.pem";
                        };
                };
            };
        };
}
