# Dendritic Refactor Plan

This repository is intended to replace the legacy flake in `vendor/nixos-flake` with a dendritic, `flake-parts` driven layout inspired by Doc-Steve's dendritic design notes. The goal is not to rewrite the configuration in one pass. The goal is to keep the old flake as the behavior oracle while moving independent pieces into aspect modules that can be worked on by agents.

## Current State

The active root `flake.nix` is only a minimal placeholder. The legacy implementation lives in `vendor/nixos-flake` and contains:

- `flake.nix`: inputs, Cachix metadata, four host entries, output construction, and templates.
- `utils.nix`: custom builders for nixpkgs imports, NixOS configurations, and Home Manager configurations.
- `options.nix`: one large shared `biryani.*` option schema consumed by both NixOS and Home Manager modules.
- `common/nixos`: shared NixOS base configuration and NixOS modules.
- `common/home-manager`: shared Home Manager base configuration and Home Manager modules.
- `common/metadata/programs`: metadata registries for selectable programs.
- `hosts/{alienrj,oracleamd1,oracleamperehyd,raspi}`: host options, hardware config, disk config where applicable, and host-specific imports.
- `templates`: dev flake templates for Go, Python Poetry, Rust binary, Rust library, and Rust workspace projects.

## Target Shape

Use a dendritic layout where each non-entrypoint Nix file is a top-level `flake-parts` module. The legacy folder structure is only a source inventory; the new layout does not need to preserve buckets like `programs`, `services`, `hardware`, or the old NixOS/Home Manager split. Prefer aspects that describe a real capability and let each aspect contribute to NixOS, Home Manager, packages, overlays, or checks as needed.

A practical target for this repo:

```text
.
|-- flake.nix
|-- flake.lock
|-- parts/
|   |-- inputs.nix
|   |-- nix-config.nix
|   |-- systems.nix
|   |-- templates.nix
|   |-- nixos-configurations.nix
|   `-- home-configurations.nix
|-- aspects/
|   |-- core/
|   |   |-- options.nix
|   |   |-- metadata.nix
|   |   |-- base-system.nix
|   |   `-- base-home.nix
|   |-- identity/
|   |   `-- akshettrj.nix
|   |-- nix/
|   |   |-- caches.nix
|   |   `-- package-sets.nix
|   |-- networking/
|   |   |-- ssh.nix
|   |   |-- firewall.nix
|   |   |-- tailscale.nix
|   |   `-- openvpn.nix
|   |-- desktop/
|   |   |-- hyprland.nix
|   |   |-- theming.nix
|   |   |-- bars.nix
|   |   |-- launchers.nix
|   |   `-- screen-capture-lock.nix
|   |-- shell/
|   |   |-- zsh.nix
|   |   |-- nushell.nix
|   |   `-- prompt-tools.nix
|   |-- editing/
|   |   |-- neovim.nix
|   |   |-- helix.nix
|   |   `-- emacs.nix
|   |-- terminal/
|   |   |-- ghostty.nix
|   |   |-- wezterm.nix
|   |   `-- alacritty.nix
|   |-- files/
|   |   |-- lf.nix
|   |   |-- yazi.nix
|   |   `-- xdg.nix
|   |-- media/
|   |   |-- audio.nix
|   |   |-- video.nix
|   |   |-- documents.nix
|   |   `-- pictures.nix
|   |-- ai/
|   |   |-- codex.nix
|   |   |-- cursor.nix
|   |   |-- gemini.nix
|   |   |-- mcp.nix
|   |   `-- ollama.nix
|   |-- self-hosting/
|   |   |-- nginx.nix
|   |   |-- glance.nix
|   |   |-- finance.nix
|   |   |-- wiki.nix
|   |   `-- watgbridge.nix
|   `-- hardware/
|       |-- nvidia-prime.nix
|       |-- bluetooth.nix
|       |-- iphone.nix
|       `-- raspberry-pi.nix
|-- hosts/
|   |-- alienrj/
|   |-- oracleamd1/
|   |-- oracleamperehyd/
|   `-- raspi/
|-- templates/
`-- docs/
```

This is a suggested shape, not a rule. The important rule is that a file is named for the feature it contributes, not for which lower-level configuration class consumes it.

## Design Rules

- Keep `vendor/nixos-flake` read-only except when explicitly comparing behavior. New work should happen outside `vendor/`.
- Use the `biryani.*` option namespace for the refactored configuration.
- Re-bucket freely. The old tree is evidence of behavior, not a target architecture.
- Prefer aspect files that own both sides of a feature. For example, `aspects/editing/neovim.nix` can expose both NixOS and Home Manager module fragments instead of splitting Neovim by `common/nixos` and `common/home-manager`.
- Let `flake-parts` own output assembly. Avoid reintroducing a new monolithic `utils.mkConfigurations` unless it is narrowly scoped and lives under `parts/`.
- Make every migration step evaluable. Each completed step should leave at least one `nix flake show` or `nix eval` command working.
- Avoid behavior edits during structural moves. If a module needs modernization, track it as a follow-up after parity.

## Migration Phases

### Phase 0: Baseline Inventory

Document what exists before moving files.

Deliverables:

- Input inventory from `vendor/nixos-flake/flake.nix`.
- Host matrix for all four machines.
- Module inventory grouped by source path and proposed aspect.
- Build/eval baseline commands for the legacy flake.

Suggested checks:

```sh
nix flake show ./vendor/nixos-flake
nix eval ./vendor/nixos-flake#nixosConfigurations.alienrj.config.networking.hostName
nix eval ./vendor/nixos-flake#homeConfigurations.'akshettrj@alienrj'.config.home.username
```

### Phase 1: Flake-Parts Skeleton

Replace the placeholder root flake with a `flake-parts` skeleton while keeping outputs minimal.

Deliverables:

- Root `flake.nix` imports `flake-parts`.
- `parts/systems.nix` defines supported systems: `x86_64-linux` and `aarch64-linux`.
- The root `flake.nix` carries the old `nixConfig` substituters and trusted keys inline. Keep `parts/nix-config.nix` as the comparable planning copy, but do not import it into top-level `nixConfig`; Nix expects a literal set there.
- `parts/templates.nix` initially exposes copied templates.
- `nix flake show` works at repo root.

### Phase 2: Inputs and Package Sets

Move old input declarations and package-set selection into the new structure.

Deliverables:

- All old inputs are declared at root or in an imported input part.
- Stable and unstable nixpkgs package sets are available to configuration builders.
- Existing overlay hook exists, even if empty.
- No host configuration is migrated yet.

Notes:

- `nixpkgs-stable` currently points at `nixos-25.05`.
- `propheci_secrets` is a private SSH input and may block evaluation on machines without access. Agents should avoid forcing it unless working on host import parity.

### Phase 3: Core Options and Metadata

Move the shared option schema and metadata registries first because most modules depend on them.

Deliverables:

- `aspects/core/options.nix` equivalent to old `options.nix`.
- Core metadata modules copied under `aspects/core/metadata/`.
- Import paths updated to the new locations.
- Option evaluation works independently through a small test host or a migrated host.

Risk:

- `options.nix` imports metadata using relative paths and requires `config`, `inputs`, and `pkgs`. Keep argument contracts unchanged during the move.

### Phase 4: Base NixOS and Home Manager Builders

Recreate the old behavior in `parts/nixos-configurations.nix` and `parts/home-configurations.nix`.

Deliverables:

- A new host manifest replaces the old inline list in `vendor/nixos-flake/flake.nix`.
- NixOS configurations are exported under the same names: `alienrj`, `oracleamd1`, `oracleamperehyd`, `raspi`.
- Home Manager configurations are exported under the same names as before, e.g. `akshettrj@alienrj`.
- `pkgs_unstable`, `pkgs_stable`, `use_stable_pkgs`, and `inputs` are still passed as module args.

Preferred host manifest shape:

```nix
{
  alienrj = {
    system = "x86_64-linux";
    allowUnfree = true;
    stable = false;
    nixosModules = [
      ./alienrj/configuration.nix
      inputs.awcc.nixosModules.default
    ];
  };
}
```

### Phase 5: Host Migration

Move one host at a time. Start with a smaller server host before the desktop host.

Recommended order:

1. `raspi`
2. `oracleamd1`
3. `oracleamperehyd`
4. `alienrj`

Deliverables per host:

- Host files copied to `hosts/<name>/`.
- Imports point at new aspect modules.
- Host-specific secret imports are preserved.
- Host eval command succeeds or the blocker is documented.

### Phase 6: Aspect Migration

Move modules into aspects, preserving option names and behavior.

Suggested aspects:

- `core`: shared options, metadata, base NixOS config, base Home Manager config.
- `nix`: package sets, Nix settings, Cachix caches, garbage collection.
- `identity`: user account, home directory, sudo/polkit defaults.
- `networking`: firewall, OpenSSH, Tailscale, OpenVPN.
- `desktop`: Hyprland, Wayland/X11 support, theming, bars, launchers, notifications, screen capture, screen locks.
- `shell`: bash, zsh, fish, nushell, aliases, eza, starship, zoxide.
- `editing`: Neovim, Helix, Emacs, Zed.
- `terminal`: Ghostty, WezTerm, Alacritty.
- `files`: LF, Yazi, XDG user dirs, MIME defaults.
- `media`: MPD, MPRIS, MPV, VLC, Stremio, Jellyfin, image viewers, document readers.
- `ai`: Codex, Cursor, Gemini, MCP, Ollama, skills.
- `self-hosting`: Nginx, Telegram Bot API, Firefly III, DokuWiki, Vikunja, Glance, Watgbridge, Navidrome, FreshRSS, AdGuard, Audiobookshelf, Overleaf.
- `hardware`: Nvidia PRIME, Bluetooth, graphics, iPhone support, Raspberry Pi specifics.

Move leaves first. When a legacy feature has both NixOS and Home Manager pieces, merge them into the same aspect file only when doing so improves clarity; otherwise keep nearby sibling files under the same aspect directory.

### Phase 7: Cleanup and Modernization

Only after parity:

- Remove duplicated legacy helpers.
- Consider renaming `biryani` options if desired.
- Split very large option files by domain.
- Add small eval checks or `nix flake check` checks.
- Decide whether `templates/` belongs in this repo or a separate template flake.

## Parity Commands

Use these commands repeatedly while migrating:

```sh
nix flake show
nix eval .#templates --json
nix eval .#nixosConfigurations.alienrj.config.networking.hostName
nix eval .#nixosConfigurations.oracleamd1.config.networking.hostName
nix eval .#nixosConfigurations.oracleamperehyd.config.networking.hostName
nix eval .#nixosConfigurations.raspi.config.networking.hostName
nix eval .#homeConfigurations.'akshettrj@alienrj'.config.home.username
```

For full builds, run only when evaluation is stable:

```sh
nix build .#nixosConfigurations.alienrj.config.system.build.toplevel
nix build .#homeConfigurations.'akshettrj@alienrj'.activationPackage
```

## Known Migration Risks

- Private secrets input: `propheci_secrets` uses SSH and will fail without credentials.
- Desktop stack inputs: Hyprland, Quickshell, Waybar, WezTerm, Ghostty, and nightly editors can make evaluation or builds slower and more fragile.
- Shared option schema: remaining unmigrated modules may still assume `config.biryani.*` exists.
- Relative imports: many host option files import old module paths directly.
- Read-only package set: old NixOS base imports `inputs.nixpkgs.nixosModules.readOnlyPkgs` and assigns `nixpkgs.pkgs`; preserve this until there is a deliberate package-set redesign.
