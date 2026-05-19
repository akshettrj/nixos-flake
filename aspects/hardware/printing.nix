{
    pkgs,
    lib,
    config,
    ...
}:
{
    options.biryani.services.printing.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable local printing support and common printer drivers.";
    };

    config =
        let
            biryani_services = config.biryani.services;
        in
        lib.mkIf biryani_services.printing.enable {
            # More at https://nixos.wiki/wiki/Printing

            services.printing.enable = true;

            environment.systemPackages = [
                pkgs.gutenprint
                pkgs.gutenprintBin
                pkgs.hplip
                pkgs.hplipWithPlugin
            ];
        };
}
