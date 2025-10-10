{
  config,
  lib,
  ...
}: {
  config = let
    pro_nginx = config.propheci.services.nginx;
  in
    lib.mkIf pro_nginx.enable {
      services.nginx = {
        enable = true;
        recommendedTlsSettings = false;
        recommendedGzipSettings = false;
        recommendedOptimisation = false;
        recommendedProxySettings = false;
        recommendedBrotliSettings = false;
      };

      users.users.nginx.extraGroups = ["acme"];
    };
}
