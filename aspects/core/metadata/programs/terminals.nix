{
    config,
    inputs,
    pkgs,
}:
let
    biryani_terminals = config.biryani.programs.terminals;

    wezterm_package = (
        if biryani_terminals.wezterm.use_official_package then
            inputs.wezterm.packages."${pkgs.stdenv.hostPlatform.system}".default
        else
            pkgs.wezterm
    );

    ghostty_package = (
        if biryani_terminals.ghostty.use_official_package then
            inputs.ghostty.packages."${pkgs.stdenv.hostPlatform.system}".default
        else
            pkgs.ghostty
    );
in
{
    alacritty = rec {
        pkg = pkgs.alacritty;
        bin = "${pkg}/bin/alacritty";
        cmd = "${bin}";
        exec = "${cmd} -e";
    };
    wezterm = rec {
        pkg = wezterm_package;
        bin = "${pkg}/bin/wezterm";
        cmd = "${bin} start --always-new-process";
        exec = "${cmd} -e";
    };
    ghostty = rec {
        pkg = ghostty_package;
        bin = "${pkg}/bin/ghostty";
        cmd = "${bin}";
        exec = "${cmd} -e";
    };
}
