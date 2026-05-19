# Parity Checklist

Track migration progress here. A box should only be checked when the root flake, not `vendor/nixos-flake`, satisfies the item.

## Output Names

- [x] `nixosConfigurations.alienrj`
- [x] `nixosConfigurations.oracleamd1`
- [x] `nixosConfigurations.oracleamperehyd`
- [x] `nixosConfigurations.raspi`
- [x] `homeConfigurations.akshettrj@alienrj`
- [x] `homeConfigurations.akshettrj@oracleamd1`
- [x] `homeConfigurations.akshettrj@oracleamperehyd`
- [x] `homeConfigurations.akshettrj@raspi`

## Host Matrix

| Host | System | allowUnfree | stable | Special modules | Disk config |
| --- | --- | --- | --- | --- | --- |
| `alienrj` | `x86_64-linux` | true | false | `inputs.awcc.nixosModules.default`, `specialisation.nix`, secrets | no |
| `oracleamd1` | `x86_64-linux` | false | false | `inputs.disko.nixosModules.disko` | yes |
| `oracleamperehyd` | `aarch64-linux` | false | false | `inputs.disko.nixosModules.disko` | yes |
| `raspi` | `aarch64-linux` | false | false | none in legacy flake entry | no |

## Root Flake

- [x] `flake-parts` input added.
- [x] `nixConfig.extra-substituters` matches legacy flake.
- [x] `nixConfig.extra-trusted-public-keys` matches legacy flake.
- [x] Supported systems include `x86_64-linux`.
- [x] Supported systems include `aarch64-linux`.
- [x] Templates from legacy flake are exported.

## Inputs

- [x] `nixpkgs`
- [x] `nixpkgs-stable`
- [x] `nixpkgs-master`
- [x] `home-manager`
- [x] `disko`
- [x] `nixos-hw`
- [x] `wallpapers`
- [x] `hyprland`
- [x] `hyprpaper`
- [x] `hyprlock`
- [x] `waybar`
- [x] `quickshell`
- [x] `wezterm`
- [x] `ghostty`
- [x] `neovim`
- [x] `helix`
- [x] `nix-index-database`
- [x] `nur`
- [x] `propheci_secrets`
- [x] `watgbridge`
- [x] `odesli`
- [x] `nixur`
- [x] `rubikoid_base`
- [x] `awcc`
- [x] `mcp_python`

## Shared Contracts

- [x] NixOS modules receive `inputs`.
- [x] NixOS modules receive `pkgs_unstable`.
- [x] NixOS modules receive `pkgs_stable`.
- [x] NixOS modules receive `use_stable_pkgs`.
- [x] Home Manager modules receive `inputs`.
- [x] Home Manager modules receive `pkgs_stable`.
- [x] Home Manager receives `biryani` from the evaluated NixOS configuration.
- [x] `config.biryani.*` option namespace is active.

## Core Eval Checks

```sh
nix flake show
nix eval .#nixosConfigurations.alienrj.config.networking.hostName
nix eval .#nixosConfigurations.oracleamd1.config.networking.hostName
nix eval .#nixosConfigurations.oracleamperehyd.config.networking.hostName
nix eval .#nixosConfigurations.raspi.config.networking.hostName
nix eval .#homeConfigurations.'akshettrj@alienrj'.config.home.username
nix eval .#homeConfigurations.'akshettrj@oracleamd1'.config.home.username
nix eval .#homeConfigurations.'akshettrj@oracleamperehyd'.config.home.username
nix eval .#homeConfigurations.'akshettrj@raspi'.config.home.username
```

## Optional Build Checks

Run these after evaluation is stable. They may be slow or require private inputs and binary caches.

```sh
nix build .#nixosConfigurations.raspi.config.system.build.toplevel
nix build .#nixosConfigurations.oracleamd1.config.system.build.toplevel
nix build .#nixosConfigurations.oracleamperehyd.config.system.build.toplevel
nix build .#nixosConfigurations.alienrj.config.system.build.toplevel
nix build .#homeConfigurations.'akshettrj@alienrj'.activationPackage
```

## Module Migration Checklist

NixOS:

- [x] `common/nixos/configuration.nix`
- [x] `common/nixos/modules/default.nix`
- [x] `hardware/default.nix`
- [x] `hardware/bluetooth.nix`
- [x] `hardware/graphics.nix`
- [x] `hardware/iphone.nix`
- [x] `hardware/nvidia.nix`
- [x] `hardware/pulseaudio.nix`
- [x] `misc/default.nix`
- [x] `misc/fonts.nix`
- [x] `programs/default.nix`
- [x] `programs/editors/*`
- [x] `programs/gaming.nix`
- [x] `programs/screenlocks/*`
- [x] `programs/shells/*`
- [x] `programs/utilities.nix`
- [x] `programs/vpn/*`
- [x] `services/default.nix`
- [x] `services/nginx.nix`
- [x] `services/openssh.nix`
- [x] `services/openvpn.nix`
- [x] `services/pipewire.nix`
- [x] `services/printing.nix`
- [x] `services/tailscale.nix`
- [x] `services/telegram_bot_api.nix`
- [x] `services/virtualisation.nix`
- [x] `services/self_hosted/*`
- [x] `theming/default.nix`
- [x] `theming/gtk.nix`

Home Manager:

- [x] `common/home-manager/configuration.nix`
- [x] `homeManagerInitModule.nix`
- [x] `homeManagerMaker.nix`
- [x] `common/home-manager/modules/default.nix`
- [x] `ai/*`
- [x] `bars/*`
- [x] `bars/quickshell/*`
- [x] `browsers/*`
- [x] `clipboard_managers/*`
- [x] `desktop_environments/*`
- [x] `desktop_environments/both/*`
- [x] `desktop_environments/wayland/*`
- [x] `desktop_environments/x11/*`
- [x] `dev/*`
- [x] `editors/*`
- [x] `file_explorers/*`
- [x] `file_explorers/lf/*`
- [x] `hardware/*`
- [x] `launchers/*`
- [x] `media/*`
- [x] `media/audio/*`
- [x] `media/audio/mpd/*`
- [x] `media/documents/*`
- [x] `media/picture/*`
- [x] `media/services/*`
- [x] `media/video/*`
- [x] `notification_daemons/*`
- [x] `screenlocks/*`
- [x] `screenshot_tools/*`
- [x] `scripts/*`
- [x] `scripts/utilities/*`
- [x] `shells/*`
- [x] `shells/utils/*`
- [x] `shells/zsh/*`
- [x] `social_media/*`
- [x] `terminals/*`
- [x] `theming/*`

## Blockers and Notes

Record any non-code blocker here:

- `propheci_secrets` may require SSH access to a private repository.
- Network access may be needed to fetch new `flake-parts` and any inputs missing from the lock file.
- Desktop builds may require caches for Hyprland, WezTerm, Helix, and other fast-moving inputs.
- Migrated Home Manager modules now define their own `biryani.*` options. `aspects/core/base-home.nix` currently bridges migrated option values from the evaluated NixOS host config into the Home Manager graph; remove that bridge incrementally if host home settings move into native Home Manager modules.
