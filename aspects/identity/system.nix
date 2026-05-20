{
    config,
    lib,
    pkgs,
    ...
}:
{
    options =
        let
            inherit (lib) mkOption types;
        in
        {
            biryani = {
                user = {
                    username = mkOption {
                        type = types.str;
                        example = "akshettrj";
                        description = "Primary user account managed by this configuration.";
                    };

                    homedir = mkOption {
                        type = types.str;
                        example = "/home/akshettrj";
                        description = "Home directory for the primary user.";
                    };
                };

                security.sudo_without_password = mkOption {
                    type = types.bool;
                    description = "Allow the primary user to run sudo commands without a password.";
                };
            };
        };

    config =
        let
            biryani_sec = config.biryani.security;
            biryani_shells = config.biryani.shells;
            biryani_user = config.biryani.user;

            shells_meta = import ../core/metadata/programs/shells.nix { inherit pkgs; };
        in
        {
            users.users."${biryani_user.username}" = {
                isNormalUser = true;
                extraGroups = [
                    "networkmanager"
                    "wheel"
                ];
                initialPassword = "12345";
                shell = shells_meta."${biryani_shells.main}".pkg;
            };

            security.sudo.extraRules = lib.mkIf biryani_sec.sudo_without_password [
                {
                    users = [ "${biryani_user.username}" ];
                    commands = [
                        {
                            command = "ALL";
                            options = [ "NOPASSWD" ];
                        }
                    ];
                }
            ];
        };
}
