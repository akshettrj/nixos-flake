{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkOption types;

    # Captured so the submodule below can reach host-wide defaults; inside
    # `types.submodule` the `config` argument refers to the submodule itself.
    hostConfig = config;

    shellsMeta = import ../core/metadata/programs/shells.nix { inherit pkgs; };
    knownShells = lib.attrNames shellsMeta;

    userType = types.submodule (
        { name, config, ... }: {
            options = {
                username = mkOption {
                    type = types.str;
                    default = name;
                    defaultText = "the attribute name";
                    example = "akshettrj";
                    description = "Login name of the account.";
                };

                homedir = mkOption {
                    type = types.str;
                    default = "/home/${config.username}";
                    defaultText = "\"/home/\${username}\"";
                    example = "/home/akshettrj";
                    description = "Home directory of the account.";
                };

                groups = mkOption {
                    type = types.listOf types.str;
                    default = [
                        "networkmanager"
                        "wheel"
                    ];
                    description = ''
                        Supplementary groups for the account. Drop `wheel` for
                        accounts that must not be able to escalate to root.
                    '';
                };

                sudo_without_password = mkOption {
                    type = types.bool;
                    default = hostConfig.biryani.security.sudo_without_password;
                    defaultText = "config.biryani.security.sudo_without_password";
                    description = ''
                        Allow this account to run sudo without a password. Has no
                        effect unless the account is also in `wheel`.
                    '';
                };

                shell = mkOption {
                    type = types.enum knownShells;
                    default = hostConfig.biryani.shells.main;
                    defaultText = "config.biryani.shells.main";
                    description = "Login shell for the account.";
                };

                initial_password = mkOption {
                    type = types.nullOr types.str;
                    default = "12345";
                    description = ''
                        Password set when the account is first created. Ignored on
                        accounts that already exist, so changing it later does
                        nothing; use `passwd` for that.
                    '';
                };

                home.enable = mkOption {
                    type = types.bool;
                    default = true;
                    description = ''
                        Generate a Home Manager configuration for this account,
                        exposed as `homeConfigurations."<username>@<host>"`.
                    '';
                };

                overrides = mkOption {
                    type = types.attrs;
                    default = { };
                    example = lib.literalExpression ''
                        {
                            programs.ai.enable = false;
                            programs.torrent.enable = false;
                        }
                    '';
                    description = ''
                        Per-account patch applied over the host's `biryani` tree
                        before it reaches this account's Home Manager graph, via
                        `lib.recursiveUpdate`.

                        This merges over already-evaluated values, so it can only
                        replace leaves. Property values such as `lib.mkForce` and
                        `lib.mkIf` are not interpreted here.
                    '';
                };
            };
        }
    );

    primaryUser = config.biryani.users.${config.biryani.primary_user};
in
{
    options.biryani = {
        users = mkOption {
            type = types.attrsOf userType;
            default = { };
            description = ''
                Accounts managed on this host, keyed by login name. Each entry
                yields a `users.users` entry and, unless `home.enable` is false,
                a Home Manager configuration.
            '';
        };

        primary_user = mkOption {
            type = types.str;
            example = "akshettrj";
            description = ''
                Key into `biryani.users` naming the account that owns the machine.
                System-level aspects resolve `biryani.user` to this entry, so
                services, shares, and state directories follow it.
            '';
        };

        # Kept as the stable read-only surface for system aspects that mean "the
        # machine's owner" rather than "the account being configured".
        user = {
            username = mkOption {
                type = types.str;
                readOnly = true;
                default = primaryUser.username;
                defaultText = "config.biryani.users.\${config.biryani.primary_user}.username";
                description = "Login name of the primary user. Set via `biryani.users`.";
            };

            homedir = mkOption {
                type = types.str;
                readOnly = true;
                default = primaryUser.homedir;
                defaultText = "config.biryani.users.\${config.biryani.primary_user}.homedir";
                description = "Home directory of the primary user. Set via `biryani.users`.";
            };
        };
    };
}
