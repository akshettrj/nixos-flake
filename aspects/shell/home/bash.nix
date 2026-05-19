{
    config,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_shells = config.biryani.shells;
            biryani_file_explorers = config.biryani.programs.file_explorers;
        in
        lib.mkIf biryani_shells.bash.enable {
            programs.bash = {
                enable = true;

                enableVteIntegration = true;
                enableCompletion = true;

                historyControl = [
                    "erasedups"
                    "ignorespace"
                ];
                historyFile = "$HOME/.cache/bash_history";
                historyIgnore = import ./history_ignore_patterns.nix;
                historySize = 10000;

                initExtra =
                    ""
                    +
                        lib.optionalString biryani_file_explorers.lf.enable # sh

                            ''

                                ###################################################

                                # LFCD
                                function lfcd() {
                                    tmp="$(mktemp)"
                                    ${pkgs.lf}/bin/lf -last-dir-path="$tmp" "$@"
                                    if [ -f "$tmp" ]; then
                                        dir="$(cat "$tmp")"
                                        rm -f "$tmp" >/dev/null
                                        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
                                    fi
                                }

                            '';
            };
        };
}
