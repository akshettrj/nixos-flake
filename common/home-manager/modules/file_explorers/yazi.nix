{
  config,
  lib,
  ...
}: {
  config = let
    pro_explorers = config.propheci.programs.file_explorers;
    pro_shells = config.propheci.shells;
  in
    lib.mkIf pro_explorers.yazi.enable {
      programs.yazi = {
        enable = true;
        shellWrapperName = "y";

        enableBashIntegration = lib.mkIf pro_shells.bash.enable true;
        enableFishIntegration = lib.mkIf pro_shells.fish.enable true;
        enableNushellIntegration = lib.mkIf pro_shells.nushell.enable true;
        enableZshIntegration = lib.mkIf pro_shells.zsh.enable true;

        settings = {
          manager = {
            # Sorting
            sort_by = "natural";
            sort_dir_first = true;
            sort_sensitive = false;

            # Visibility
            show_hidden = true;
            show_symlink = true;

            title_format = "[yazi]: {cwd}";
          };

          preview = {
            wrap = "yes";
            tab_size = 2;
            image_delay = 100;
          };
        };
      };
    };
}
