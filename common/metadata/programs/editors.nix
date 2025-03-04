{
  config,
  inputs,
  pkgs,
}: let
  pro_editors = config.propheci.programs.editors;

  neovim_package = (
    if pro_editors.neovim.nightly
    then inputs.neovim.packages."${pkgs.system}".neovim
    else pkgs.neovim
  );
  helix_package = (
    if pro_editors.helix.nightly
    then inputs.helix.packages."${pkgs.system}".helix
    else pkgs.helix
  );
in {
  helix = rec {
    pkg = helix_package;
    cmd = "${pkg}/bin/hx";
  };
  neovim = rec {
    pkg = neovim_package;
    cmd = "${pkg}/bin/nvim";
  };
  zeditor = rec {
    pkg = pkgs.zed-editor;
    cmd = "${pkg}/bin/zeditor";
  };
}
