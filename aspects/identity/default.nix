{ biryani, ... }:
let
    biryani_user = biryani.user;
in
{
    home.username = biryani_user.username;
    home.homeDirectory = biryani_user.homedir;
}
