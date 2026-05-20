{
    config,
    inputs,
    lib,
    pkgs,
    biryani,
    ...
}:
{
    imports = [ ./home-modules.nix ];

    config =
        let
            biryani_browsers = biryani.programs.browsers;
            biryani_editors = biryani.programs.editors;
            biryani_terminals = biryani.programs.terminals;
            biryani_config = { inherit biryani; };

            browsers_meta = import ./metadata/programs/browsers.nix { inherit pkgs; };
            editors_meta = import ./metadata/programs/editors.nix {
                config = biryani_config;
                inherit inputs pkgs;
            };
            terminals_meta = import ./metadata/programs/terminals.nix {
                config = biryani_config;
                inherit inputs pkgs;
            };
        in
        {
            programs.home-manager.enable = true;

            home.stateVersion = "23.11";

            home.sessionVariables = {
                EDITOR = editors_meta."${biryani_editors.main}".cmd;
                VISUAL = editors_meta."${biryani_editors.main}".cmd;
                SUDO_EDITOR = editors_meta."${biryani_editors.main}".cmd;

                GOPATH = "${config.xdg.dataHome}/golang";
            }
            // lib.optionalAttrs biryani_terminals.enable {
                TERMINAL = terminals_meta."${biryani_terminals.main}".cmd;
                BROWSER = browsers_meta."${biryani_browsers.main}".cmd;
            };

            home.packages = with pkgs; [
                bat
                (btop.override { cudaSupport = true; })
                dust
                fd
                nh
                nixd
                ripgrep
            ];

            home.preferXdgDirectories = true;
            xdg = {
                enable = true;
                userDirs = {
                    enable = true;
                    createDirectories = true;
                    setSessionVariables = true;
                    desktop = "${config.home.homeDirectory}/media/desktop";
                    documents = "${config.home.homeDirectory}/media/documents";
                    download = "${config.home.homeDirectory}/media/downloads";
                    music = "${config.home.homeDirectory}/media/music";
                    publicShare = "${config.home.homeDirectory}/media/public";
                    templates = "${config.home.homeDirectory}/media/templates";
                    videos = "${config.home.homeDirectory}/media/videos";
                    pictures = "${config.home.homeDirectory}/media/pictures";
                    projects = "${config.home.homeDirectory}/media/projects";
                };
            };
        };
}
