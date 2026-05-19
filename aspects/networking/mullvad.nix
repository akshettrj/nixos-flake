{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.programs.vpn.mullvad.enable = lib.mkEnableOption "Mullvad VPN client";

    config =
        let
            biryani_vpn = config.biryani.programs.vpn;
        in
        lib.mkIf biryani_vpn.mullvad.enable {
            services.mullvad-vpn = {
                enable = true;
                enableExcludeWrapper = false;
                enableEarlyBootBlocking = false;
            };

            environment.systemPackages = [ pkgs.mullvad-vpn ];
        };
}
