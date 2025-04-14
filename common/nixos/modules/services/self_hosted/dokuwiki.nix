{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_doku = config.propheci.services.self_hosted.dokuwiki;
  in
    lib.mkIf pro_doku.enable {
      services.dokuwiki = {
        webserver = "nginx";
        sites = {
          "${pro_doku.hostname}" = {
            settings = {
              # Basic Settings
              title = "The PropheC's Wiki";
              start = "index";
              template = "bootstrap3";
              tagline = "A hub for knowledge aggregated by me";

              # Display Settings
              recent = 200;
              recent_days = 36;
              typography = 0;
              dformat = "%d/%m/%Y %H:%M (%f)";
              toptoclevel = 2;
              deaccent = 1;
              useheading = 1;

              # Authentication Settings
              useacl = true;
              autopasswd = 0;
              passcrypt = "argon2id";
              superuser = "@admin";
              disableactions=(if pro_doku.disable_registration then "register" else "");

              # Media Settings
              mediarevisions = 0;
              im_convert = "${pkgs.imagemagick}/bin/convert";

              # Syndication Settings
              rss_type = "atom1";
              rss_linkto = "page";
              rss_content = "abstract";
              rss_media = "pages";
              rss_show_summary = 0;

              # Advanced Options
              updatecheck = 0;
              userewrite = 1;
              fnencode = "safe";

              # Plugins and Templates
              tpl = {
                bootstrap3 = {
                  bootstrapTheme = "bootswatch";
                  showThemeSwitcher = true;
                  bootswatchTheme = "spacelab";
                  tocAffix = false;
                  useGoogleAnalytics = false;
                };
              };
              plugin = {
                graphviz.path = "${pkgs.graphviz}/bin/dot";
              };
            };
            plugins = (
              inputs.nixur.legacyPackages."${pkgs.system}".dokuwikiPlugins
              |> lib.attrValues
            );
            templates = (
              inputs.nixur.legacyPackages."${pkgs.system}".dokuwikiTemplates
              |> lib.attrValues
            );
            acl = [
              {
                page = "*";
                actor = "@ALL";
                level = 0;
              }
              {
                page = "*";
                actor = "@user";
                level = 16;
              }
              {
                page = "*";
                actor = "@ex";
                level = 1;
              }
            ];
          };
        };
      };

      services.nginx = {
        virtualHosts = {
          "${pro_doku.hostname}" = let
            certDir = config.security.acme.certs."${pro_doku.hostname}".directory;
          in {
            forceSSL = pro_doku.nginx.enable_ssl;
            sslCertificate = "${certDir}/cert.pem";
            sslCertificateKey = "${certDir}/key.pem";
          };
        };
      };
    };
}

