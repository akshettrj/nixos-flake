{ biryani, ... }:
{
    config.biryani.shells = {
        aliases = biryani.shells.aliases;
        bash.enable = biryani.shells.bash.enable;
        eza.enable = biryani.shells.eza.enable;
        fish.enable = biryani.shells.fish.enable;
        main = biryani.shells.main;
        nushell.enable = biryani.shells.nushell.enable;
        starship.enable = biryani.shells.starship.enable;
        zoxide.enable = biryani.shells.zoxide.enable;
        zsh.enable = biryani.shells.zsh.enable;
    };
}
