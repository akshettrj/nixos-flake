{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_vpn = config.propheci.programs.vpn;
  in lib.mkIf pro_vpn.mullvad.enable {
    services.mullvad-vpn = {
      enable = true;
      enableExcludeWrapper = false;
      enableEarlyBootBlocking = false;
    };

    environment.systemPackages = [ pkgs.mullvad-vpn ];
  };
}

