{
  inputs,
  nixpkgs,
  nixpkgs-stable,
}:
rec {
    mkPkgs = {system, allowUnfree, overlays}: let
      mkPkg = { pkgsBranch }: import pkgsBranch {
        inherit system overlays;
        config = {
          inherit allowUnfree;
          allowUnsafe = false;
        };
      };
    in {
      unstable = mkPkg { pkgsBranch = nixpkgs; };
      stable = mkPkg { pkgsBranch = nixpkgs-stable; };
    };

    mkNixosConfiguration = entry: systemPkgs: nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        pkgs_unstable = systemPkgs.unstable;
        pkgs_stable = systemPkgs.stable;
      };
      modules = entry.nixosModules;
    };

    mkHomeConfiguration = entry: systemPkgs: nixosConfiguration: {
      name = "${nixosConfiguration.config.propheci.user.username}@${nixosConfiguration.config.propheci.system.hostname}";
      value = import ./common/home-manager/homeManagerMaker.nix
      {
        inherit inputs;
        pkgs = systemPkgs.unstable;
        config = nixosConfiguration.config;
      };
    };

    mkConfigurations = configsList: overlays: builtins.listToAttrs (map (entry: let
      systemPkgs = mkPkgs {
        inherit overlays;
        system = entry.system;
        allowUnfree = entry.allowUnfree;
      };
    in {
      name = entry.name;
      value = rec {
        inherit systemPkgs;
        nixosConfiguration = mkNixosConfiguration entry systemPkgs;
        homeConfiguration = mkHomeConfiguration entry systemPkgs nixosConfiguration;
      };
    }) configsList);
}
