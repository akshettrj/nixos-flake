# Legacy Inventory

This is the Task A inventory for migrating `vendor/nixos-flake` into a dendritic `flake-parts` layout. The legacy path tables are source inventory. Target paths are proposed landing spots, not a requirement to preserve the old feature buckets. During implementation, prefer aspect names that describe the capability being configured, even when that means merging old NixOS and Home Manager pieces into one aspect.

## Inputs

| Input | Source | Use area | Notes |
| --- | --- | --- | --- |
| `nixpkgs` | `github:nixos/nixpkgs/nixos-unstable` | NixOS, Home Manager, packages | Main unstable package set. |
| `nixpkgs-stable` | `github:nixos/nixpkgs/nixos-25.05` | NixOS, Home Manager | Stable package set passed as `pkgs_stable`. |
| `nixpkgs-master` | `github:nixos/nixpkgs` | NixOS | Added to `nix.nixPath` as `nixpkgs-master`. |
| `home-manager` | `github:nix-community/home-manager` | Home Manager, NixOS packages | Follows `nixpkgs`. Used for `homeManagerConfiguration` and installed as a package. |
| `disko` | `github:nix-community/disko` | Host-only NixOS | Used by `oracleamd1` and `oracleamperehyd`. |
| `nixos-hw` | `github:NixOS/nixos-hardware` | Host-only NixOS | Used by `raspi` for Raspberry Pi 4 support. |
| `wallpapers` | `github:Propheci/wallpapers` | Home Manager options | Non-flake input. Used in host theming/screenlock options. |
| `hyprland` | `git+https://github.com/hyprwm/Hyprland?submodules=1` | Desktop/Home Manager | Official Hyprland packages and portal. |
| `hyprpaper` | `github:hyprwm/hyprpaper` | Desktop/Home Manager | Hyprland wallpaper tooling. |
| `hyprlock` | `github:hyprwm/hyprlock` | Desktop/Home Manager | Screenlock module. |
| `waybar` | `github:Alexays/Waybar` | Desktop/Home Manager | Bar module. |
| `quickshell` | `github:quickshell-mirror/quickshell` | Desktop/Home Manager | Follows `nixpkgs`. |
| `wezterm` | `github:wez/wezterm?dir=nix` | Home Manager | Official WezTerm package option. |
| `ghostty` | `github:ghostty-org/ghostty` | Home Manager | Official Ghostty package option. |
| `neovim` | `github:nix-community/neovim-nightly-overlay` | NixOS, Home Manager | Nightly editor option. |
| `helix` | `github:helix-editor/helix` | NixOS, Home Manager | Nightly editor option. |
| `nix-index-database` | `github:nix-community/nix-index-database` | NixOS | Imported by base NixOS configuration. |
| `nur` | `github:nix-community/NUR` | Packages/modules | Keep available until usage is audited. |
| `propheci_secrets` | `git+ssh://git@github.com/akshettrj/nixos_flake_secrets.git` | Host-only NixOS | Private non-flake input. Likely evaluation blocker without SSH access. |
| `watgbridge` | `github:akshettrj/watgbridge` | NixOS services | Used by self-hosted `watgbridge` option defaults/modules. |
| `odesli` | `github:Propheci/odesli-rs?dir=nix` | Home Manager programs | Follows `nixpkgs`. |
| `nixur` | `github:Propheci/NixUR` | Packages/modules | Keep available until usage is audited. |
| `rubikoid_base` | `github:Rubikoid/nix-base` | Packages/modules | Follows `nixpkgs`; keep available until usage is audited. |
| `awcc` | `github:akshettrj/AWCC` | Host-only NixOS | Used by `alienrj`. Follows `nixpkgs`. |
| `mcp_python` | `github:akshettrj/personal-mcp-py` | Home Manager AI | Used by `alienrj` MCP server config. Follows `nixpkgs`. |

## Host Matrix

| Host | System | allowUnfree | stable | State version | Extra modules/imports | Disk config | Host profile |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `alienrj` | `x86_64-linux` | true | false | `23.11` | `inputs.awcc.nixosModules.default`, `specialisation.nix`, private secrets | no | Desktop/laptop with Nvidia PRIME, Hyprland, AI tools, media, browsers, terminals, Tailscale, Telegram Bot API. |
| `oracleamd1` | `x86_64-linux` | false | false | `23.11` | `inputs.disko.nixosModules.disko`, private secrets | yes | Server with Docker/rootless containers, SSH, Tailscale, file explorers, editors, shells. |
| `oracleamperehyd` | `aarch64-linux` | false | false | `24.11` | `inputs.disko.nixosModules.disko`, private secrets | yes | Server with OpenVPN, Nginx, Telegram Bot API, self-hosted services, Tailscale, editors, shells. |
| `raspi` | `aarch64-linux` | false | false | `24.05` | `inputs.nixos-hw.nixosModules.raspberry-pi-4`, private secrets | no | Raspberry Pi 4 with extlinux boot, RPi kernel, redistributable firmware, lightweight desktop/media setup. |

## Host File Mapping

| Legacy path | Target path |
| --- | --- |
| `vendor/nixos-flake/hosts/alienrj/configuration.nix` | `hosts/alienrj/configuration.nix` |
| `vendor/nixos-flake/hosts/alienrj/hardware-configuration.nix` | `hosts/alienrj/hardware-configuration.nix` |
| `vendor/nixos-flake/hosts/alienrj/options.nix` | `hosts/alienrj/options.nix` |
| `vendor/nixos-flake/hosts/alienrj/specialisation.nix` | `hosts/alienrj/specialisation.nix` |
| `vendor/nixos-flake/hosts/oracleamd1/configuration.nix` | `hosts/oracleamd1/configuration.nix` |
| `vendor/nixos-flake/hosts/oracleamd1/disk-config.nix` | `hosts/oracleamd1/disk-config.nix` |
| `vendor/nixos-flake/hosts/oracleamd1/hardware-configuration.nix` | `hosts/oracleamd1/hardware-configuration.nix` |
| `vendor/nixos-flake/hosts/oracleamd1/options.nix` | `hosts/oracleamd1/options.nix` |
| `vendor/nixos-flake/hosts/oracleamperehyd/configuration.nix` | `hosts/oracleamperehyd/configuration.nix` |
| `vendor/nixos-flake/hosts/oracleamperehyd/disk-config.nix` | `hosts/oracleamperehyd/disk-config.nix` |
| `vendor/nixos-flake/hosts/oracleamperehyd/hardware-configuration.nix` | `hosts/oracleamperehyd/hardware-configuration.nix` |
| `vendor/nixos-flake/hosts/oracleamperehyd/options.nix` | `hosts/oracleamperehyd/options.nix` |
| `vendor/nixos-flake/hosts/raspi/configuration.nix` | `hosts/raspi/configuration.nix` |
| `vendor/nixos-flake/hosts/raspi/hardware-configuration.nix` | `hosts/raspi/hardware-configuration.nix` |
| `vendor/nixos-flake/hosts/raspi/options.nix` | `hosts/raspi/options.nix` |

## Root and Parts Mapping

| Legacy path | Target path | Notes |
| --- | --- | --- |
| `vendor/nixos-flake/flake.nix` | `flake.nix`, `parts/*.nix`, `hosts/default.nix` | Split inputs, nixConfig, host manifest, outputs, and templates. |
| `vendor/nixos-flake/utils.nix` | `parts/nixos-configurations.nix`, `parts/home-configurations.nix`, `parts/pkgs.nix` | Recreate behavior through flake-parts modules. |
| `vendor/nixos-flake/options.nix` | `aspects/core/options.nix` | Current namespace is `biryani.*`; remaining shared declarations should move beside their modules. |
| `vendor/nixos-flake/templates/golang/**` | `templates/golang/**` | Copy as-is. |
| `vendor/nixos-flake/templates/python_poetry/**` | `templates/python_poetry/**` | Copy as-is. |
| `vendor/nixos-flake/templates/rust/**` | `templates/rust/**` | Copy as-is. |
| `vendor/nixos-flake/templates/rust_lib/**` | `templates/rust_lib/**` | Copy as-is. |
| `vendor/nixos-flake/templates/rust_workspace/**` | `templates/rust_workspace/**` | Copy as-is. |

## Core and Metadata Mapping

These should move early because most other aspects depend on them.

| Legacy path | Target path |
| --- | --- |
| `vendor/nixos-flake/common/metadata/programs/browsers.nix` | `aspects/core/metadata/browsers.nix` |
| `vendor/nixos-flake/common/metadata/programs/clipboard_managers.nix` | `aspects/core/metadata/clipboard-managers.nix` |
| `vendor/nixos-flake/common/metadata/programs/desktop_environments.nix` | `aspects/core/metadata/desktop-environments.nix` |
| `vendor/nixos-flake/common/metadata/programs/editors.nix` | `aspects/core/metadata/editors.nix` |
| `vendor/nixos-flake/common/metadata/programs/file_explorers.nix` | `aspects/core/metadata/file-explorers.nix` |
| `vendor/nixos-flake/common/metadata/programs/launchers.nix` | `aspects/core/metadata/launchers.nix` |
| `vendor/nixos-flake/common/metadata/programs/notification_daemons.nix` | `aspects/core/metadata/notification-daemons.nix` |
| `vendor/nixos-flake/common/metadata/programs/screenlocks.nix` | `aspects/core/metadata/screenlocks.nix` |
| `vendor/nixos-flake/common/metadata/programs/screenshot_tools.nix` | `aspects/core/metadata/screenshot-tools.nix` |
| `vendor/nixos-flake/common/metadata/programs/shells.nix` | `aspects/core/metadata/shells.nix` |
| `vendor/nixos-flake/common/metadata/programs/terminals.nix` | `aspects/core/metadata/terminals.nix` |
| `vendor/nixos-flake/common/nixos/configuration.nix` | `aspects/core/base-system.nix` |
| `vendor/nixos-flake/common/home-manager/configuration.nix` | `aspects/core/base-home.nix` |
| `vendor/nixos-flake/common/home-manager/homeManagerInitModule.nix` | `aspects/core/home-init.nix` |
| `vendor/nixos-flake/common/home-manager/homeManagerMaker.nix` | `aspects/core/home-maker.nix`, called later by `parts/home-configurations.nix` |

## NixOS Module Aspect Map

| Legacy paths | Proposed aspect |
| --- | --- |
| `vendor/nixos-flake/common/nixos/modules/default.nix` | `aspects/core/base-system.nix` or an aggregate imported by it |
| `vendor/nixos-flake/common/nixos/modules/hardware/default.nix` | `aspects/hardware/*` aggregate |
| `vendor/nixos-flake/common/nixos/modules/hardware/bluetooth.nix` | `aspects/hardware/bluetooth.nix` |
| `vendor/nixos-flake/common/nixos/modules/hardware/graphics.nix` | `aspects/hardware/graphics.nix` |
| `vendor/nixos-flake/common/nixos/modules/hardware/iphone.nix` | `aspects/hardware/iphone.nix` |
| `vendor/nixos-flake/common/nixos/modules/hardware/nvidia.nix` | `aspects/hardware/nvidia-prime.nix` |
| `vendor/nixos-flake/common/nixos/modules/hardware/pulseaudio.nix` | `aspects/media/audio.nix` or `aspects/hardware/audio.nix` |
| `vendor/nixos-flake/common/nixos/modules/misc/default.nix` | `aspects/core/*` aggregate |
| `vendor/nixos-flake/common/nixos/modules/misc/fonts.nix` | `aspects/desktop/fonts.nix` |
| `vendor/nixos-flake/common/nixos/modules/programs/default.nix` | Split across `aspects/editing`, `aspects/shell`, `aspects/desktop`, `aspects/networking`, and `aspects/gaming` |
| `vendor/nixos-flake/common/nixos/modules/programs/editors/default.nix` | `aspects/editing/*` aggregate |
| `vendor/nixos-flake/common/nixos/modules/programs/editors/emacs.nix` | `aspects/editing/emacs.nix` |
| `vendor/nixos-flake/common/nixos/modules/programs/editors/helix.nix` | `aspects/editing/helix.nix` |
| `vendor/nixos-flake/common/nixos/modules/programs/editors/neovim.nix` | `aspects/editing/neovim.nix` |
| `vendor/nixos-flake/common/nixos/modules/programs/gaming.nix` | `aspects/gaming/default.nix` |
| `vendor/nixos-flake/common/nixos/modules/programs/screenlocks/default.nix` | `aspects/desktop/screen-lock.nix` |
| `vendor/nixos-flake/common/nixos/modules/programs/screenlocks/hyprlock.nix` | `aspects/desktop/screen-lock.nix` |
| `vendor/nixos-flake/common/nixos/modules/programs/screenlocks/swaylock.nix` | `aspects/desktop/screen-lock.nix` |
| `vendor/nixos-flake/common/nixos/modules/programs/shells/default.nix` | `aspects/shell/*` aggregate |
| `vendor/nixos-flake/common/nixos/modules/programs/shells/bash.nix` | `aspects/shell/bash.nix` |
| `vendor/nixos-flake/common/nixos/modules/programs/shells/fish.nix` | `aspects/shell/fish.nix` |
| `vendor/nixos-flake/common/nixos/modules/programs/shells/zsh.nix` | `aspects/shell/zsh.nix` |
| `vendor/nixos-flake/common/nixos/modules/programs/utilities.nix` | `aspects/core/system-tools.nix` |
| `vendor/nixos-flake/common/nixos/modules/programs/vpn/default.nix` | `aspects/networking/vpn.nix` |
| `vendor/nixos-flake/common/nixos/modules/programs/vpn/mullvad.nix` | `aspects/networking/mullvad.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/default.nix` | Split across `aspects/networking`, `aspects/media`, `aspects/self-hosting`, and `aspects/virtualisation` |
| `vendor/nixos-flake/common/nixos/modules/services/nginx.nix` | `aspects/self-hosting/nginx.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/openssh.nix` | `aspects/networking/ssh.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/openvpn.nix` | `aspects/networking/openvpn.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/pipewire.nix` | `aspects/media/audio.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/printing.nix` | `aspects/hardware/printing.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/tailscale.nix` | `aspects/networking/tailscale.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/telegram_bot_api.nix` | `aspects/self-hosting/telegram-bot-api.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/virtualisation.nix` | `aspects/virtualisation/containers.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/self_hosted/default.nix` | `aspects/self-hosting/*` aggregate |
| `vendor/nixos-flake/common/nixos/modules/services/self_hosted/adguard.nix` | `aspects/self-hosting/adguard.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/self_hosted/audiobookshelf.nix` | `aspects/self-hosting/audiobookshelf.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/self_hosted/dokuwiki.nix` | `aspects/self-hosting/wiki.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/self_hosted/firefly_iii.nix` | `aspects/self-hosting/finance.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/self_hosted/freshrss.nix` | `aspects/self-hosting/rss.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/self_hosted/glance.nix` | `aspects/self-hosting/glance.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/self_hosted/navidrome.nix` | `aspects/self-hosting/music.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/self_hosted/overleaf_docker.nix` | `aspects/self-hosting/overleaf.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/self_hosted/vikunja.nix` | `aspects/self-hosting/tasks.nix` |
| `vendor/nixos-flake/common/nixos/modules/services/self_hosted/watgbridge.nix` | `aspects/self-hosting/watgbridge.nix` |
| `vendor/nixos-flake/common/nixos/modules/theming/default.nix` | `aspects/desktop/theming.nix` |
| `vendor/nixos-flake/common/nixos/modules/theming/gtk.nix` | `aspects/desktop/theming.nix` |

## Home Manager Module Aspect Map

| Legacy paths | Proposed aspect |
| --- | --- |
| `vendor/nixos-flake/common/home-manager/modules/default.nix` | `aspects/core/base-home.nix` or an aggregate imported by it |
| `vendor/nixos-flake/common/home-manager/modules/ai/*` | `aspects/ai/*`, split by tool: Codex, Cursor, Gemini, MCP, Ollama, skills |
| `vendor/nixos-flake/common/home-manager/modules/bars/*` | `aspects/desktop/bars.nix` or one file per bar |
| `vendor/nixos-flake/common/home-manager/modules/bars/quickshell/default.nix` | `aspects/desktop/quickshell.nix` |
| `vendor/nixos-flake/common/home-manager/modules/browsers/*` | `aspects/browsing/*`, split by browser if useful |
| `vendor/nixos-flake/common/home-manager/modules/clipboard_managers/*` | `aspects/desktop/clipboard.nix` |
| `vendor/nixos-flake/common/home-manager/modules/desktop_environments/*` | `aspects/desktop/*`, split by Hyprland, Wayland, X11, and shared desktop behavior |
| `vendor/nixos-flake/common/home-manager/modules/dev/*` | `aspects/development/*`, split by Git, Direnv, Cachix |
| `vendor/nixos-flake/common/home-manager/modules/editors/*` | `aspects/editing/*`, split by editor |
| `vendor/nixos-flake/common/home-manager/modules/file_explorers/*` | `aspects/files/*`, split by LF and Yazi |
| `vendor/nixos-flake/common/home-manager/modules/file_explorers/lf/*` | `aspects/files/lf.nix` or nearby LF helper files |
| `vendor/nixos-flake/common/home-manager/modules/hardware/*` | `aspects/hardware/*`, merge with matching NixOS hardware aspects where clear |
| `vendor/nixos-flake/common/home-manager/modules/launchers/*` | `aspects/desktop/launchers.nix` |
| `vendor/nixos-flake/common/home-manager/modules/media/*` | `aspects/media/*`, split by audio, video, documents, pictures, and MPRIS |
| `vendor/nixos-flake/common/home-manager/modules/media/audio/mpd/*` | `aspects/media/audio.nix` or `aspects/media/mpd.nix` |
| `vendor/nixos-flake/common/home-manager/modules/notification_daemons/*` | `aspects/desktop/notifications.nix` |
| `vendor/nixos-flake/common/home-manager/modules/screenlocks/*` | `aspects/desktop/screen-lock.nix` |
| `vendor/nixos-flake/common/home-manager/modules/screenshot_tools/*` | `aspects/desktop/screen-capture.nix` |
| `vendor/nixos-flake/common/home-manager/modules/scripts/*` | `aspects/scripts/*` or merge scripts into the feature that uses them |
| `vendor/nixos-flake/common/home-manager/modules/scripts/utilities/*` | `aspects/scripts/utilities.nix` |
| `vendor/nixos-flake/common/home-manager/modules/shells/*` | `aspects/shell/*`, split by shell and prompt/tooling |
| `vendor/nixos-flake/common/home-manager/modules/shells/utils/*` | `aspects/shell/prompt-tools.nix` |
| `vendor/nixos-flake/common/home-manager/modules/shells/zsh/*` | `aspects/shell/zsh.nix` |
| `vendor/nixos-flake/common/home-manager/modules/social_media/*` | `aspects/communication/*` |
| `vendor/nixos-flake/common/home-manager/modules/terminals/*` | `aspects/terminal/*`, split by terminal |
| `vendor/nixos-flake/common/home-manager/modules/theming/*` | `aspects/desktop/theming.nix` |

## Risk Notes

- `propheci_secrets` is private and uses SSH. Avoid making it part of early skeleton checks.
- Some modules still depend on relative imports into old metadata and shell aliases. Update those paths during file moves.
- `options.nix` computes enum values from metadata files and needs `config`, `inputs`, and `pkgs`.
- The old NixOS base sets `nixpkgs.pkgs` after importing `inputs.nixpkgs.nixosModules.readOnlyPkgs`; preserve this until package-set behavior is intentionally redesigned.
- `alienrj` has the largest blast radius because it exercises Nvidia, Hyprland, AI tooling, media, browsers, terminals, theming, and private secrets.
- `oracleamperehyd` has the largest service surface because it exercises OpenVPN, Nginx, Telegram Bot API, and multiple self-hosted modules.
- The `wallpapers` paths contain a multiplication sign in filenames, for example `1920×1080`; preserve the exact Unicode path while moving host options.
