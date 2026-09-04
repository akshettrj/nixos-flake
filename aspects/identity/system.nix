{
    config,
    lib,
    pkgs,
    ...
}:
{
    imports = [ ./users-options.nix ];

    options =
        let
            inherit (lib) mkOption types;
        in
        {
            biryani.security.sudo_without_password = mkOption {
                type = types.bool;
                description = ''
                    Host-wide default for `biryani.users.<name>.sudo_without_password`.
                    Individual accounts can opt out of it.
                '';
            };
        };

    config =
        let
            biryani_users = config.biryani.users;

            shells_meta = import ../core/metadata/programs/shells.nix { inherit pkgs; };
        in
        {
            users.users = lib.mapAttrs' (
                _: user:
                lib.nameValuePair user.username {
                    isNormalUser = true;
                    home = user.homedir;
                    extraGroups = user.groups;
                    initialPassword = user.initial_password;
                    shell = shells_meta."${user.shell}".pkg;
                }
            ) biryani_users;

            security.sudo.extraRules = lib.mapAttrsToList (_: user: {
                users = [ user.username ];
                commands = [
                    {
                        command = "ALL";
                        options = [ "NOPASSWD" ];
                    }
                ];
            }) (lib.filterAttrs (_: user: user.sudo_without_password) biryani_users);
        };
}
