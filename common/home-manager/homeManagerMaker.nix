{
  pkgs,
  pkgs_stable,
  inputs,
  config,
}:
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = {
    inherit inputs pkgs pkgs_stable;
    propheci = config.propheci;
  };
  modules = [./homeManagerInitModule.nix];
}
