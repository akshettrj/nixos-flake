{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_bars = config.biryani.programs.bars;

            quickshell_pkg = (
                if biryani_bars.quickshell.use_official_package then
                    inputs.quickshell.packages."${pkgs.stdenv.hostPlatform.system}".default
                else
                    pkgs.quickshell
            );
        in
        lib.mkIf (biryani_bars.enable && biryani_bars.quickshell.enable) {
            programs.quickshell = {
                enable = true;
                package = quickshell_pkg;
                configs = {
                    hello-world = ./configs/hello-world;
                    multi-monitor-clock = ./configs/multi-monitor-clock;
                };
            };

            systemd.user.services =
                biryani_bars.quickshell.enabled_configs
                |> map (config_name: {
                    name = "quickshell-${config_name}";
                    value = {
                        Unit = {
                            Description = "quickshell-${config_name}";
                            Documentation = "https://quickshell.outfoxxed.me/docs/";
                            After = [ biryani_bars.quickshell.systemd_target ];
                        };

                        Service = {
                            ExecStart =
                                lib.getExe quickshell_pkg + (if config_name == null then "" else " --config ${config_name}");
                            Restart = "on-failure";
                        };

                        Install.WantedBy = [ biryani_bars.quickshell.systemd_target ];
                    };
                })
                |> builtins.listToAttrs;

            home.packages = [
                pkgs.kdePackages.qtdeclarative
                pkgs.kdePackages.qtsvg
                pkgs.kdePackages.qtimageformats
                pkgs.kdePackages.qtmultimedia
                pkgs.kdePackages.qt5compat
            ];
        };
}
