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
            biryani_theming = config.biryani.theming;

            quickshell_pkg = (
                if biryani_bars.quickshell.use_official_package then
                    inputs.quickshell.packages."${pkgs.stdenv.hostPlatform.system}".default
                else
                    pkgs.quickshell
            );

            palette =
                if biryani_theming.matugen.integrations.quickshell.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;

            biryani_shell_theme = pkgs.writeText "Theme.qml" ''
                pragma Singleton
                import QtQuick
                import Quickshell

                Singleton {
                    readonly property color background: "${palette.background}"
                    readonly property color surface: "${palette.surface}"
                    readonly property color surface_container: "${palette.surface_container}"
                    readonly property color surface_container_high: "${palette.surface_container_high}"
                    readonly property color on_surface: "${palette.on_surface}"
                    readonly property color on_surface_variant: "${palette.on_surface_variant}"
                    readonly property color primary: "${palette.primary}"
                    readonly property color on_primary: "${palette.on_primary}"
                    readonly property color outline: "${palette.outline}"

                    readonly property color barBackground: Qt.alpha(background, 0.82)
                    readonly property color island: Qt.alpha(surface_container, 0.94)
                    readonly property color islandActive: Qt.alpha(surface_container_high, 0.97)
                    readonly property color islandBorder: Qt.alpha(outline, 0.55)

                    readonly property color warning: "#e5a50a"
                    readonly property color critical: "${palette.error}"

                    readonly property int barHeight: 48
                    readonly property int islandHeight: 36
                    readonly property int islandRadius: 8
                    readonly property int fontSize: 14
                    readonly property int iconSize: 16
                    readonly property string fontFamily: "${biryani_theming.fonts.main.name}"
                }
            '';

            biryani_shell = pkgs.runCommandLocal "quickshell-biryani-shell" { } ''
                mkdir -p "$out"
                cp -r ${./configs/biryani-shell}/. "$out/"
                cp ${biryani_shell_theme} "$out/Theme.qml"
            '';
        in
        lib.mkIf (biryani_bars.enable && biryani_bars.quickshell.enable) {
            programs.quickshell = {
                enable = true;
                package = quickshell_pkg;
                configs = {
                    hello-world = ./configs/hello-world;
                    multi-monitor-clock = ./configs/multi-monitor-clock;
                    biryani-shell = biryani_shell;
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
