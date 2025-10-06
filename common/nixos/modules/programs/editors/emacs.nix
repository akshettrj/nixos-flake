{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_editors = config.propheci.programs.editors;
  in
    lib.mkIf pro_editors.emacs.enable {
      services.emacs = {
        enable = true;
        install = true;
      };
    };
}
