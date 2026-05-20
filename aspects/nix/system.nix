{
    config,
    inputs,
    lib,
    pkgs_unstable,
    pkgs_stable,
    use_stable_pkgs,
    ...
}:
{
    imports = [
        inputs.nix-index-database.nixosModules.nix-index
        inputs.nixpkgs.nixosModules.readOnlyPkgs
    ];

    options.biryani.nix =
        let
            inherit (lib) mkOption types;
        in
        {
            garbage_collection.enable = mkOption {
                type = types.bool;
                description = "Enable automatic Nix store garbage collection.";
            };

            nix_community_cache = mkOption {
                type = types.bool;
                description = "Trust and use the nix-community binary cache.";
            };

            hyprland_cache = mkOption {
                type = types.bool;
                description = "Trust and use the Hyprland binary cache.";
            };

            helix_cache = mkOption {
                type = types.bool;
                description = "Trust and use the Helix binary cache.";
            };

            wezterm_cache = mkOption {
                type = types.bool;
                description = "Trust and use the WezTerm binary cache.";
            };
        };

    config =
        let
            biryani_nix = config.biryani.nix;
            biryani_user = config.biryani.user;
        in
        {
            nix = {
                nixPath = [
                    "nixpkgs=${inputs.nixpkgs}"
                    "nixpkgs-master=${inputs.nixpkgs-master}"
                ];
                settings = {
                    experimental-features = "nix-command flakes pipe-operators";
                    auto-optimise-store = true;
                    extra-substituters = [
                        "https://propheci.cachix.org"
                        "https://watgbridge.cachix.org"
                    ]
                    ++ lib.optionals biryani_nix.nix_community_cache [ "https://nix-community.cachix.org" ]
                    ++ lib.optionals biryani_nix.hyprland_cache [ "https://hyprland.cachix.org" ]
                    ++ lib.optionals biryani_nix.helix_cache [ "https://helix.cachix.org" ]
                    ++ lib.optionals biryani_nix.wezterm_cache [ "https://wezterm.cachix.org" ];
                    extra-trusted-public-keys = [
                        "propheci.cachix.org-1:CwV87KMySX+rhW88NhTx2hRzdNltV497nhXvWswFGDc="
                        "watgbridge.cachix.org-1:KSfgmbSBvXQTpUnoCj21vST7zgwpy3SbNfk0/nesR1Y="
                    ]
                    ++ lib.optionals biryani_nix.nix_community_cache [
                        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                    ]
                    ++ lib.optionals biryani_nix.hyprland_cache [
                        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
                    ]
                    ++ lib.optionals biryani_nix.helix_cache [
                        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
                    ]
                    ++ lib.optionals biryani_nix.wezterm_cache [
                        "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
                    ];
                    trusted-users = [
                        "root"
                        "${biryani_user.username}"
                    ];
                    show-trace = true;
                    eval-cache = false;
                };
                gc = lib.mkIf biryani_nix.garbage_collection.enable {
                    automatic = true;
                    dates = "weekly";
                    options = "--delete-older-than 7d";
                };
            };

            nixpkgs.pkgs = if use_stable_pkgs then pkgs_stable else pkgs_unstable;

            programs.command-not-found.enable = false;
        };
}
