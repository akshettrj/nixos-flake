{ config, pkgs }:
let
    biryani_theming = config.biryani.theming;

    ueberzugpp =
        if biryani_theming.enable then
            "${pkgs.ueberzugpp}/bin/ueberzugpp"
        else
            "random_non_existing_binary";
in
pkgs.writeShellScript "cleaner.sh" /* sh */ ''
    set -C -f

    (command -V ${ueberzugpp} > /dev/null 2>&1) && ${ueberzugpp} cmd -s $UB_SOCKET -a remove -i PREVIEW
''
