{
    config,
    inputs,
    lib,
    ...
}:
let
    mkSystemPkgs =
        entry:
        config.flake.lib.mkPkgs {
            inherit (entry) system allowUnfree;
            overlays = [ config.flake.overlays.default ];
        };

    mkNixosConfiguration =
        entry: systemPkgs:
        let
            nixpkgsInput = if entry.stable then inputs.nixpkgs-stable else inputs.nixpkgs;
        in
        nixpkgsInput.lib.nixosSystem {
            specialArgs = {
                inherit inputs;
                pkgs_unstable = systemPkgs.unstable;
                pkgs_stable = systemPkgs.stable;
                use_stable_pkgs = entry.stable;
            };
            modules = entry.nixosModules;
        };

    mkHomeConfiguration =
        systemPkgs: nixosConfiguration:
        import ../aspects/core/home-maker.nix {
            inherit inputs;
            pkgs = systemPkgs.unstable;
            pkgs_stable = systemPkgs.stable;
            config = nixosConfiguration.config;
        };

    allConfigurations = lib.mapAttrs (
        _: entry:
        let
            systemPkgs = mkSystemPkgs entry;
            nixosConfiguration = mkNixosConfiguration entry systemPkgs;
            homeConfiguration = mkHomeConfiguration systemPkgs nixosConfiguration;
        in
        {
            inherit systemPkgs nixosConfiguration homeConfiguration;
        }
    ) config.flake.hosts;

    homeConfigurationPairs = {
        "akshettrj@alienrj" = "alienrj";
        "akshettrj@oracleamd1ca" = "oracleamd1ca";
        "akshettrj@oracleamperehyd" = "oracleamperehyd";
        "akshettrj@raspi" = "raspi";
    };
in
{
    options.flake.hosts = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "Host manifest used to generate NixOS and Home Manager outputs.";
    };

    config.flake = {
        inherit allConfigurations;

        nixosConfigurations = lib.mapAttrs (_: value: value.nixosConfiguration) allConfigurations;

        homeConfigurations = lib.mapAttrs (
            _: hostName: allConfigurations.${hostName}.homeConfiguration
        ) homeConfigurationPairs;
    };
}
