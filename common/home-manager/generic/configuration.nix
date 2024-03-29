{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ../modules/display-managers/hyprland/hyprland.nix
    ../modules/launchers/bemenu.nix
    ../modules/shells/zsh.nix
    ../modules/shells/bash.nix
    ../modules/shells/eza.nix
    ../modules/shells/starship.nix
    ../modules/shells/zoxide.nix
    ../modules/file_explorers/lf.nix
    ../modules/terminals/wezterm.nix
    ../modules/theming/gtk.nix
    ../modules/theming/qt.nix
    ../modules/browsers/brave.nix
    ../modules/unison.nix
    ../modules/mpd.nix
  ];

  options = let
    inherit (lib) mkOption mkEnableOption types;
    known_terminals = ["wezterm" "alacritty"];
    known_editors = ["neovim" "helix"];
    known_browsers = ["brave" "chrome" "firefox" "chromium"];
  in {
    username = mkOption { type = types.str; example = "akshettrj"; };

    homedirectory = mkOption { type = types.str; example = "/home/akshettrj"; };

    editors = {
      main = mkOption { type = types.enum(known_editors); example = "neovim"; };
      backup = mkOption { type = types.enum(known_editors); example = "helix"; };
    };

    terminals = {
      enable = mkOption { type = types.bool; description = "Enable terminals"; };

      main = mkOption { type = types.enum(known_terminals); example = "wezterm"; };
      backup = mkOption { type = types.enum(known_terminals); example = "alacritty"; };
    };

    browsers = {
      main = mkOption { type = types.enum(known_browsers); example = "brave"; };
      backups = mkOption { type = types.listOf(types.enum(known_browsers)); example = ["firefox" "chrome"]; };
    };

    hasDisplay = mkOption { type = types.bool; description = "Enable if has display"; };

    theming = {
      gtk = mkOption { type = types.bool; example = true; };
      qt = mkOption { type = types.bool; example = true; };
      fontconfig = mkOption { type = types.bool; example = true; };
      cursorSize = mkOption { type = types.number; example = 16; };
      font = mkOption { type = types.str; example = "Iosevka NF"; };
      fontSize = mkOption { type = types.number; example = 15; };
    };

    shell.aliases = mkOption { type = types.attrsOf (types.str); };

    minBrightness = mkOption { type = types.number; };
  };

  config = let
    terminal_configs = {
      "alacritty" = rec { package = pkgs.alacritty; binary = "${package}/bin/alacritty"; command = "${package}/bin/alacritty"; };
      "wezterm" = rec { package = pkgs.wezterm; binary = "${package}/bin/wezterm"; command = "${package}/bin/wezterm start --always-new-process"; };
    };

    editor_configs = {
      "neovim" = rec { package = pkgs.neovim; binary = "${package}/bin/nvim"; command = "${package}/bin/nvim"; };
      "helix" = rec { package = pkgs.helix; binary = "${package}/bin/hx"; command = "${package}/bin/hx"; };
    };

    browser_configs = {
      "brave" = rec { package = pkgs.brave; binary = "${package}/bin/brave"; command = "${binary}"; };
      "chrome" = rec { package = pkgs.google-chrome; binary = "${package}/bin/google-chrome-stable"; command = "${binary}"; };
      "firefox" = rec { package = pkgs.firefox; binary = "${package}/bin/firefox"; command = "${binary}"; };
      "chromium" = rec { package = pkgs.chromium; binary = "${package}/bin/chromium"; command = "${binary}"; };
    };

    editors = {
      main = editor_configs."${config.editors.main}";
      backup = editor_configs."${config.editors.backup}";
    };

    terminals = {
      main = terminal_configs."${config.terminals.main}";
      backup = terminal_configs."${config.terminals.backup}";
    };

    browsers = {
      main = browser_configs."${config.browsers.main}";
      backups = map(b: browser_configs."${b}")(config.browsers.backups);
    };

  in {

    home.username = "${config.username}";
    home.homeDirectory = "${config.homedirectory}";

    home.stateVersion = "23.11"; # Please read the comment before changing.

    home.packages = with pkgs; [

      btop
      ripgrep

    ] ++ lib.optionals config.hasDisplay(
      [
        terminals.main.package
        terminals.backup.package

        browsers.main.package

        inputs.telegram-desktop-userfonts.packages.telegram-desktop-userfonts
        pcmanfm
      ] ++ map(b: b.package)(browsers.backups)
    );

    home.file = {
    #   # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    #   # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    #   # # symlink to the Nix store copy.
    #   # ".screenrc".source = dotfiles/screenrc;

    #   # # You can also set the file content immediately.
    #   # ".gradle/gradle.properties".text = ''
    #   #   org.gradle.console=verbose
    #   #   org.gradle.daemon.idletimeout=3600000
    #   # '';
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. If you don't want to manage your shell through Home
    # Manager then you have to manually source 'hm-session-vars.sh' located at
    # either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/akshettrj/etc/profile.d/hm-session-vars.sh
    #
    home.sessionVariables = {
      UNISON = "${config.xdg.dataHome}/unison";

      EDITOR = "${editors.main.binary}";
      VISUAL = "${editors.main.binary}";
      SUDO_EDITOR = "${editors.main.binary}";
    } // lib.optionalAttrs config.hasDisplay {
      TERMINAL = "${terminals.main.binary}";
      BROWSER = "${browsers.main.binary}";
    };

    xdg.enable = true;

    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/media/desktop";
      documents = "${config.home.homeDirectory}/media/documents";
      download = "${config.home.homeDirectory}/media/downloads";
      music = "${config.home.homeDirectory}/media/music";
      publicShare = "${config.home.homeDirectory}/media/public";
      templates = "${config.home.homeDirectory}/media/templates";
      videos = "${config.home.homeDirectory}/media/videos";
      pictures = "${config.home.homeDirectory}/media/pictures";
    };

    xdg.portal = lib.mkIf config.hasDisplay {
      enable = true;
      config.common.default = "";
      extraPortals = with pkgs; [
        xdg-desktop-portal
      ] ++ lib.optionals config.hyprland.enable [
        xdg-desktop-portal-hyprland
      ];
    };

    programs.git = {
      enable = true;
      userName = "Akshett Rai Jindal";
      userEmail = "jindalakshett@gmail.com";
      delta.enable = true;
      extraConfig = {
        init.defaultBranch = "main";
      };
    };

    hyprland = lib.mkIf config.hyprland.enable {
      terminalCommand = terminals.main.command;
      backupTerminalCommand = terminals.backup.command;
      terminalCommandExecutor = "${terminals.main.binary} -e";
      backupTerminalCommandExecutor = "${terminals.backup.binary} -e";
    };

    shell.aliases = {
      cp = "cp -rvi";
      rm = "rm -vi";
      rsycn = "rsync -urvP";
    };

    starship.enable = true;
    zoxide.enable = true;
    eza.enable = true;

    programs.home-manager.enable = true;
  };
}
