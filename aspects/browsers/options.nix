{ lib, pkgs, ... }:
let
    knownBrowsers = lib.attrNames (import ../core/metadata/programs/browsers.nix { inherit pkgs; });
in
{
    options.biryani.programs.browsers = {
        enable = lib.mkEnableOption "browser configuration.";

        main = lib.mkOption {
            type = lib.types.enum knownBrowsers;
            description = "Primary browser used for default applications and session variables.";
        };

        brave = {
            enable = lib.mkEnableOption "Brave browser.";
            cmd_args = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                description = "Command-line arguments passed to Brave.";
            };
        };

        firefox.enable = lib.mkEnableOption "Firefox browser.";

        chromium = {
            enable = lib.mkEnableOption "Chromium browser.";
            cmd_args = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                description = "Command-line arguments passed to Chromium.";
            };
            extensions = lib.mkOption {
                type = lib.types.anything;
                description = "Chromium extension declarations.";
            };
        };

        chrome = {
            enable = lib.mkEnableOption "Google Chrome browser.";
            cmd_args = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                description = "Command-line arguments passed to Chrome.";
            };
            extensions = lib.mkOption {
                type = lib.types.anything;
                description = "Chrome extension declarations.";
            };
        };
    };
}
