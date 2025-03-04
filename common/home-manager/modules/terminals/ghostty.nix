{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_terminals = config.propheci.programs.terminals;

    terminals_meta = import ../../../metadata/programs/terminals.nix {
      inherit config inputs pkgs;
    };
  in
    lib.mkIf (pro_terminals.enable && pro_terminals.ghostty.enable) {
      home.packages = [terminals_meta.ghostty.pkg];
    };
}
