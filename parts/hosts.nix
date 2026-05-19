{ inputs, ... }:
{
    flake.hosts = {
        alienrj = {
            system = "x86_64-linux";
            allowUnfree = true;
            stable = false;
            nixosModules = [
                ../hosts/alienrj/configuration.nix
                inputs.awcc.nixosModules.default
            ];
        };

        oracleamperehyd = {
            system = "aarch64-linux";
            allowUnfree = false;
            stable = false;
            nixosModules = [
                ../hosts/oracleamperehyd/configuration.nix
                inputs.disko.nixosModules.disko
            ];
        };

        oracleamd1 = {
            system = "x86_64-linux";
            allowUnfree = false;
            stable = false;
            nixosModules = [
                ../hosts/oracleamd1/configuration.nix
                inputs.disko.nixosModules.disko
            ];
        };

        raspi = {
            system = "aarch64-linux";
            allowUnfree = false;
            stable = false;
            nixosModules = [ ../hosts/raspi/configuration.nix ];
        };
    };
}
