{
    biryani,
    lib,
    pkgs,
    ...
}:
let
    biryaniBrowsers = biryani.programs.browsers;
    knownBrowsers = lib.attrNames (import ../core/metadata/programs/browsers.nix { inherit pkgs; });
in
{
    options.biryani.programs.browsers.main = lib.mkOption {
        type = lib.types.enum knownBrowsers;
        description = "Primary browser used for default applications, session variables, and desktop keybindings.";
    };

    config.biryani.programs.browsers = {
        inherit (biryaniBrowsers) enable main;
        brave = biryaniBrowsers.brave;
        chrome = biryaniBrowsers.chrome;
        chromium = biryaniBrowsers.chromium;
        firefox.enable = biryaniBrowsers.firefox.enable;
    };
}
