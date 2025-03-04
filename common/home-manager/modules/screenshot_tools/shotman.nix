{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_ss_tools = config.propheci.programs.screenshot_tools;

    ss_tools_meta = import ../../../../common/metadata/programs/screenshot_tools.nix {
      inherit pkgs;
    };
  in
    lib.mkIf (pro_ss_tools.enable && pro_ss_tools.shotman.enable) {
      home.packages = [ss_tools_meta.shotman.pkg] ++ lib.attrValues (ss_tools_meta.shotman.deps);
    };
}
