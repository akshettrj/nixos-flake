{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_dev = config.propheci.dev;
  in
    lib.mkIf pro_dev.git.enable {
      programs.git = {
        enable = true;
        settings = {
          init.defaultBranch = pro_dev.git.default_branch;
          user = {
            name = pro_dev.git.user.name;
            email = pro_dev.git.user.email;
          };
        };
      };

      programs.delta.enable = pro_dev.git.delta.enable;

      home.packages = [pkgs.gitu];
    };
}
