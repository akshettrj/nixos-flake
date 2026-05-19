{
    config,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_ss_tools = config.biryani.programs.screenshot_tools;

            ss_tools_meta = import ../../core/metadata/programs/screenshot_tools.nix { inherit pkgs; };
        in
        lib.mkIf (biryani_ss_tools.enable && biryani_ss_tools.shotman.enable) {
            home.packages = [ ss_tools_meta.shotman.pkg ] ++ lib.attrValues (ss_tools_meta.shotman.deps);
        };
}
