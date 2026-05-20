# Agent Work Queue

Use this file to split the refactor into independent tasks. Each task should produce a small, reviewable change and must not modify `vendor/nixos-flake` unless the task explicitly says so.

## Coordination Rules

- Agents should state their owned files before editing.
- Agents should preserve option names and behavior unless the task explicitly asks for cleanup.
- Agents should update imports mechanically and avoid formatting churn outside touched files.
- Agents should not preserve old feature buckets by default. Use the old tree as a source inventory and choose target aspect names that fit the new design.
- An aspect may own both NixOS and Home Manager fragments for the same capability.
- Agents should run the listed acceptance checks when possible.
- If a check cannot run because of private inputs, network access, or missing binary caches, document the exact blocker.
- Agents working in parallel should use disjoint write areas.

## Task A: Inventory and Mapping

Owner scope:

- `docs/inventory.md`
- `docs/parity-checklist.md`

Goal:

Create a detailed source inventory and a proposed aspect map. The map should not be treated as a commitment to preserve the legacy buckets.

Inputs to inspect:

- `vendor/nixos-flake/flake.nix`
- `vendor/nixos-flake/options.nix`
- `vendor/nixos-flake/common/**`
- `vendor/nixos-flake/hosts/**`

Deliverables:

- Table of old inputs and whether each is used by NixOS, Home Manager, templates, or host-only code.
- Table of hosts with system, allowUnfree, stable, disk config, hardware config, and extra modules.
- Table of module paths mapped to proposed aspects.

Acceptance:

- Every old `common/**.nix` file appears in the mapping.
- Every host file appears in the mapping.

## Task B: Flake-Parts Skeleton

Owner scope:

- `flake.nix`
- `parts/systems.nix`
- `parts/nix-config.nix`
- `parts/templates.nix`
- `templates/**`

Goal:

Replace the placeholder flake with an evaluable `flake-parts` root without migrating hosts.

Deliverables:

- `flake-parts` input added.
- `nixConfig` copied from legacy flake. Keep it inline in `flake.nix`; Nix requires top-level `nixConfig` to be a literal set, not an imported thunk.
- Supported systems defined.
- Templates copied and exported.

Acceptance:

```sh
nix flake show
nix eval .#templates --json
```

## Task C: Inputs and Package Sets

Owner scope:

- `flake.nix`
- `parts/inputs.nix` if used
- `parts/overlays.nix`
- `parts/pkgs.nix` or equivalent

Goal:

Port all legacy inputs and expose stable/unstable package sets to later host builders.

Deliverables:

- All inputs from `vendor/nixos-flake/flake.nix` present.
- `nixpkgs`, `nixpkgs-stable`, and `nixpkgs-master` available.
- Overlay extension point preserved.
- No host output required yet.

Acceptance:

```sh
nix flake metadata
nix flake show
```

## Task D: Core Aspects

Owner scope:

- `aspects/core/**`

Goal:

Move the shared option schema, metadata registries, and base configuration entry points.

Source files:

- `vendor/nixos-flake/options.nix`
- `vendor/nixos-flake/common/metadata/**`
- `vendor/nixos-flake/common/nixos/configuration.nix`
- `vendor/nixos-flake/common/home-manager/configuration.nix`
- `vendor/nixos-flake/common/home-manager/homeManagerInitModule.nix`
- `vendor/nixos-flake/common/home-manager/homeManagerMaker.nix`

Deliverables:

- New core aspect paths exist.
- Relative imports point inside `aspects/core`.
- No domain-specific leaf modules moved in this task, except aggregate imports can reference future aspects if necessary.

Acceptance:

- Files evaluate syntactically with `nix-instantiate --parse` where possible.
- Later host tasks can import the core base-system aspect.

## Task E: Host Builder Parts

Owner scope:

- `parts/nixos-configurations.nix`
- `parts/home-configurations.nix`
- `hosts/default.nix` or `parts/hosts.nix`

Goal:

Recreate old `utils.mkConfigurations` behavior using `flake-parts`.

Deliverables:

- Host manifest with entries for all four hosts.
- NixOS output names match legacy names.
- Home Manager output names match legacy names.
- Module args remain compatible with old modules.

Acceptance:

```sh
nix eval .#nixosConfigurations.raspi.config.networking.hostName
nix eval .#nixosConfigurations.oracleamd1.config.networking.hostName
```

## Task F: Server Hosts

Owner scope:

- `hosts/raspi/**`
- `hosts/oracleamd1/**`
- `hosts/oracleamperehyd/**`

Goal:

Migrate non-desktop hosts first.

Deliverables:

- Host files copied from vendor.
- Imports updated to the new core and aspect paths.
- Disko imports preserved for `oracleamd1` and `oracleamperehyd`.
- Secret imports preserved but not forced during tests.

Acceptance:

```sh
nix eval .#nixosConfigurations.raspi.config.networking.hostName
nix eval .#nixosConfigurations.oracleamd1.config.networking.hostName
nix eval .#nixosConfigurations.oracleamperehyd.config.networking.hostName
```

## Task G: Desktop Host

Owner scope:

- `hosts/alienrj/**`

Goal:

Migrate the desktop host after the shared aspects are usable.

Deliverables:

- Host files copied from vendor.
- `specialisation.nix` preserved.
- AWCC module import preserved.
- Desktop, AI, theming, media, and Hyprland-related options evaluate.

Acceptance:

```sh
nix eval .#nixosConfigurations.alienrj.config.networking.hostName
nix eval .#homeConfigurations.'akshettrj@alienrj'.config.home.username
```

## Task H: System-Facing Aspects

Owner scope:

- `aspects/networking/**`
- `aspects/self-hosting/**`
- `aspects/hardware/**`
- system-facing portions of `aspects/desktop/**`, `aspects/editing/**`, `aspects/shell/**`, and `aspects/nix/**`

Goal:

Move NixOS leaf modules out of `vendor/nixos-flake/common/nixos/modules` into aspect-oriented files.

Deliverables:

- Leaf files copied or merged by aspect.
- Aggregate imports updated.
- Old relative metadata imports updated.

Acceptance:

```sh
nix eval .#nixosConfigurations.oracleamd1.config.services.openssh.enable
nix eval .#nixosConfigurations.alienrj.config.networking.hostName
```

## Task I: Home-Facing Aspects

Status:

- `ai/*` is migrated into the AI aspect for Codex, Cursor, Gemini, MCP, and Ollama Home Manager modules.
- `bars/*` and `bars/quickshell/*` are migrated into the desktop bars aspect.
- `browsers/*` and `dev/*` are migrated into `aspects/browsers/**` and `aspects/dev/**`.
- `clipboard_managers/*`, `hardware/*`, and `launchers/*` are migrated into desktop and hardware aspects.
- `desktop_environments/*` is migrated into the desktop environments aspect for Hyprland, Wayland, and X11 Home Manager modules.
- `editors/*` is migrated into the editing aspect for Home Manager packages.
- `file_explorers/*` and `file_explorers/lf/*` are migrated into the files aspect.
- `media/*` is migrated into the media aspect for Home Manager audio, video, document, picture, and MPRIS modules.
- `notification_daemons/*`, `screenlocks/*`, and `screenshot_tools/*` are migrated into desktop aspects.
- `scripts/*` and `scripts/utilities/*` are migrated into the scripts aspect.
- `shells/*`, `shells/utils/*`, and `shells/zsh/*` are migrated into the shell aspect, with shared Home Manager shell options consolidated there.
- `social_media/*` and `terminals/*` are migrated into communication and terminal aspects.
- `theming/*` is migrated into the desktop theming aspect, with shared Home Manager theme options consolidated there.
- Migrated Home Manager modules define the option leaves they consume, including descriptions.
- `aspects/<aspect>/home-bridge.nix` bridges migrated values from the evaluated NixOS host config into the matching Home Manager aspect while host option values still live in NixOS host modules.

Owner scope:

- home-facing portions of `aspects/ai/**`
- home-facing portions of `aspects/desktop/**`
- home-facing portions of `aspects/dev/**`
- home-facing portions of `aspects/editing/**`
- home-facing portions of `aspects/files/**`
- home-facing portions of `aspects/media/**`
- home-facing portions of `aspects/shell/**`
- home-facing portions of `aspects/terminal/**`

Goal:

Move Home Manager leaf modules out of `vendor/nixos-flake/common/home-manager/modules` into aspect-oriented files.

Deliverables:

- Leaf files copied or merged by aspect.
- Aggregate imports updated.
- Metadata imports point at `aspects/core/metadata`.

Acceptance:

```sh
nix eval .#homeConfigurations.'akshettrj@oracleamd1'.config.home.username
nix eval .#homeConfigurations.'akshettrj@alienrj'.config.home.sessionVariables.EDITOR
```

## Task J: Parity and Cleanup

Owner scope:

- `docs/parity-checklist.md`
- `flake.nix`
- `parts/**`
- cleanup-only changes outside `vendor/`

Goal:

Verify root outputs match old output names and remove temporary shims.

Deliverables:

- Parity checklist completed.
- Any temporary compatibility modules documented or removed.
- Follow-up modernization issues listed.

Acceptance:

```sh
nix flake show
nix eval .#nixosConfigurations.alienrj.config.system.stateVersion
nix eval .#nixosConfigurations.oracleamd1.config.system.stateVersion
nix eval .#nixosConfigurations.oracleamperehyd.config.system.stateVersion
nix eval .#nixosConfigurations.raspi.config.system.stateVersion
```

## Suggested Parallel Batches

Batch 1:

- Task A: Inventory and Mapping
- Task B: Flake-Parts Skeleton

Batch 2:

- Task C: Inputs and Package Sets
- Task D: Core Cell

Batch 3:

- Task E: Host Builder Parts
- Task F: Server Hosts

Batch 4:

- Task H: NixOS Domain Cells
- Task I: Home Manager Domain Cells

Batch 5:

- Task G: Desktop Host
- Task J: Parity and Cleanup
