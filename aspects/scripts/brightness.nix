{
    config,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_theming = config.biryani.theming;

            brightnessdown = pkgs.writeShellScriptBin "brightnessdown" ''
                ${pkgs.brightnessctl}/bin/brightnessctl -q --min-value=${toString (biryani_theming.minimum_brightness)} set -- '-'"''${1:-10}%"
            '';
            brightnessup = pkgs.writeShellScriptBin "brightnessup" ''
                ${pkgs.brightnessctl}/bin/brightnessctl -q set -- '+'"''${1:-10}%"
            '';
        in
        lib.mkIf biryani_theming.enable {
            home.packages = [
                brightnessdown
                brightnessup
            ];
        };
}
