{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_editors = config.propheci.programs.editors;

    editors_meta = import ../../../metadata/programs/editors.nix {
      inherit config inputs pkgs;
    };
  in
    lib.mkIf pro_editors.neovim.enable {
      home.packages = [editors_meta.neovim.pkg];
    };
}
