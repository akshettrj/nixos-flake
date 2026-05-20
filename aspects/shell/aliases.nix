let
    config_flake_path = "~/.config/nixos-flake";
in
{
    cp = "cp -rvi";
    rm = "rm -vi";
    rsync = "rsync -urvP";
    nh-switch = "nh os switch ${config_flake_path}";
    nh-boot = "nh os boot ${config_flake_path}";
    nh-build = "nh os build ${config_flake_path}";
    hm-switch = "home-manager switch --flake ${config_flake_path} |& nom";
    hm-news = "home-manager news --flake ${config_flake_path}";

    vimwiki = "nvim +'VimwikiUISelect'";
}
