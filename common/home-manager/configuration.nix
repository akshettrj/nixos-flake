{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../options.nix
    ./modules
  ];

  config = let
    pro_browsers = config.propheci.programs.browsers;
    pro_deskenvs = config.propheci.desktop_environments;
    pro_editors = config.propheci.programs.editors;
    pro_services = config.propheci.services;
    pro_terminals = config.propheci.programs.terminals;
    pro_user = config.propheci.user;

    browsers_meta = import ../metadata/programs/browsers.nix {inherit pkgs;};
    editors_meta = import ../metadata/programs/editors.nix {inherit config inputs pkgs;};
    terminals_meta = import ../metadata/programs/terminals.nix {inherit config inputs pkgs;};
  in {
    programs.home-manager.enable = true;

    home.username = pro_user.username;
    home.homeDirectory = pro_user.homedir;
    home.stateVersion = "23.11";

    home.sessionVariables =
      {
        EDITOR = editors_meta."${pro_editors.main}".cmd;
        VISUAL = editors_meta."${pro_editors.main}".cmd;
        SUDO_EDITOR = editors_meta."${pro_editors.main}".cmd;

        GOPATH = "${config.xdg.dataHome}/golang";
      }
      // lib.optionalAttrs pro_terminals.enable {
        TERMINAL = terminals_meta."${pro_terminals.main}".cmd;
        BROWSER = browsers_meta."${pro_browsers.main}".cmd;
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
      portal = lib.mkIf pro_services.xdg_portal.enable {
        enable = true;
        config = {
          common.default = ["gtk"];
          hyprland.default = [
            "gtk"
            "hyprland"
          ];
        };
        extraPortals =
          [
            pkgs.xdg-desktop-portal-gtk
          ]
          ++ lib.optionals pro_deskenvs.hyprland.enable [
            (
              if pro_deskenvs.hyprland.use_official_packages
              then inputs.hyprland.packages."${pkgs.system}".xdg-desktop-portal-hyprland
              else pkgs.xdg-desktop-portal-hyprland
            )
          ];
      };
      mimeApps = {
        enable = true;
        associations = {
          added = {
            "x-scheme-handler/tg" = ["org.telegram.desktop.desktop"];
            "x-scheme-handler/tonsite" = ["org.telegram.desktop.desktop"];
            "x-scheme-handler/msteams" = ["teams-for-linux.desktop"];
          };
        };
        defaultApplications = let
          image_desktop_entries = [
            "sxiv.desktop"
            "feh.desktop"
          ];
        in {
          "x-scheme-handler/tg" = ["org.telegram.desktop.desktop"];
          "x-scheme-handler/tonsite" = ["org.telegram.desktop.desktop"];
          "x-scheme-handler/msteams" = ["teams-for-linux.desktop"];
          "application/pdf" = ["sioyek.desktop" "org.pwmt.zathura-pdf-mupdf.desktop"];
          "image/png" = image_desktop_entries;
          "image/jpeg" = image_desktop_entries;
          "image/webp" = image_desktop_entries;
        };
      };
    };
  };
}
