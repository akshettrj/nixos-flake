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

    # One Home Manager configuration per `biryani.users` entry that opts into
    # one, keyed "<username>@<host>".
    mkHomeConfigurations =
        hostName: systemPkgs: nixosConfiguration:
        lib.mapAttrs' (
            _: user:
            lib.nameValuePair "${user.username}@${hostName}" (
                import ../aspects/core/home-maker.nix {
                    inherit inputs user;
                    pkgs = systemPkgs.unstable;
                    pkgs_stable = systemPkgs.stable;
                    config = nixosConfiguration.config;
                }
            )
        ) (lib.filterAttrs (_: user: user.home.enable) nixosConfiguration.config.biryani.users);

    allConfigurations = lib.mapAttrs (
        hostName: entry:
        let
            systemPkgs = mkSystemPkgs entry;
            nixosConfiguration = mkNixosConfiguration entry systemPkgs;
            homeConfigurations = mkHomeConfigurations hostName systemPkgs nixosConfiguration;
        in
        {
            inherit systemPkgs nixosConfiguration homeConfigurations;
        }
    ) config.flake.hosts;
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

        homeConfigurations = lib.foldl' (acc: entry: acc // entry.homeConfigurations) { } (
            lib.attrValues allConfigurations
        );
    };
}
