{ ... }: {
    imports = [
        ../home-bridge.nix
        ../bars
        ../clipboard.nix
        ../environments
        ../launcher.nix
        ../notifications/dunst.nix
        ../notifications/init.nix
        ../notifications/swaync.nix
        ../screenlocks/hyprlock-home.nix
        ../screenlocks/swaylock-home.nix
        ../screenshot-tools
        ../theming
        ../xdg.nix
    ];
}
