{ biryani, ... }:
let
    biryaniBrowsers = biryani.programs.browsers;
in
{
    config.biryani.programs.browsers = {
        inherit (biryaniBrowsers) enable;
        brave = biryaniBrowsers.brave;
        chrome = biryaniBrowsers.chrome;
        chromium = biryaniBrowsers.chromium;
        firefox.enable = biryaniBrowsers.firefox.enable;
    };
}
