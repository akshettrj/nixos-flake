{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_shells = config.propheci.shells;
    pro_terminals = config.propheci.programs.terminals;
    pro_theming = config.propheci.theming;

    terminals_meta = import ../../../metadata/programs/terminals.nix {
      inherit config inputs pkgs;
    };
  in
    lib.mkIf (pro_terminals.enable && pro_terminals.ghostty.enable) {
      programs.ghostty = {
        enable = true;

        package = terminals_meta.ghostty.pkg;

        enableBashIntegration = lib.mkIf pro_shells.bash.enable true;
        enableZshIntegration = lib.mkIf pro_shells.zsh.enable true;
        enableFishIntegration = lib.mkIf pro_shells.fish.enable true;

        settings = {
          theme = "Gruvbox Dark";
          font-family = "${pro_theming.fonts.main.name}";
          window-decoration = false;
          alpha-blending = "linear-corrected";
          background-opacity = pro_terminals.ghostty.background_opacity;
          background-blur = pro_terminals.ghostty.background_blur;
        };
      };
    };
}
