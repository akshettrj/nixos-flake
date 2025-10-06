{
  cp = "cp -rvi";
  rm = "rm -vi";
  rsync = "rsync -urvP";
  nh-switch = "nh os switch ~/.config/nixos-flake";
  nh-boot = "nh os boot ~/.config/nixos-flake";
  nh-build = "nh os build ~/.config/nixos-flake";
  hm-switch = "home-manager switch --flake ~/.config/nixos-flake |& nom";
  hm-news = "home-manager news --flake ~/.config/nixos-flake";

  vimwiki = "nvim +'VimwikiUISelect'";
}
