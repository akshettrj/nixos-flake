---
name: dendritic-nix
description: Manage this dendritic NixOS and Home Manager flake. Use when editing hosts, aspects, flake inputs, options, templates, docs/options.json, validation commands, or repo-local AI skills in this dendritic-nix repository.
---

# Dendritic Nix Flake

This repository is a `flake-parts` NixOS and Home Manager configuration at
`~/.config/dendritic-nix`.

## Shape

- `flake.nix`: root inputs, cache settings, and flake-parts imports.
- `parts/`: output assembly, hosts, package sets, overlays, systems, templates, formatter.
- `hosts/<host>/`: host hardware, disk, and option values.
- `aspects/<feature>/`: feature-owned NixOS/Home Manager modules and option declarations.
- `aspects/core/`: thin base aggregators, metadata, and base package/home wiring.
- `docs/`: generated options page only.

Hosts:

- `alienrj`
- `oracleamd1`
- `oracleamperehyd`
- `raspi`

## Dendritic Rules

- Put option declarations beside the module that consumes them.
- Keep old buckets out of new work; name files by capability, not by legacy source path.
- Keep core thin. Move feature behavior into an aspect.
- If a feature has both NixOS and Home Manager wiring, keep both under the same aspect.
- Preserve behavior unless the user explicitly asks for modernization.
- Do not edit `vendor/` except for comparison.

## Common Workflows

When changing options or module declarations:

1. Edit the owning aspect.
2. Regenerate the options data:
   ```sh
   nix eval --impure --file docs/options-data.nix --json > docs/options.json
   ```
3. Run:
   ```sh
   nix fmt
   nix flake show
   ```

When changing host imports or private secrets:

- The private secrets input is `private_secrets`.
- Host imports use:
  ```nix
  "${inputs.private_secrets}/hosts/<host>"
  ```

When running builds:

- Use `nom` and 16 jobs/cores:
  ```sh
  nom build <attr> --option max-jobs 16 --cores 16
  ```

## No-Build Checks

Use these before builds:

```sh
nix eval --raw .#nixosConfigurations.alienrj.config.networking.hostName
nix eval --raw .#nixosConfigurations.oracleamd1.config.networking.hostName
nix eval --raw .#nixosConfigurations.oracleamperehyd.config.networking.hostName
nix eval --raw .#nixosConfigurations.raspi.config.networking.hostName
nix eval --raw .#homeConfigurations.'akshettrj@alienrj'.config.home.username
nix eval --raw .#homeConfigurations.'akshettrj@oracleamd1'.config.home.username
nix eval --raw .#homeConfigurations.'akshettrj@oracleamperehyd'.config.home.username
nix eval --raw .#homeConfigurations.'akshettrj@raspi'.config.home.username
```

## Commit Hygiene

- Keep build validation separate from broad structural edits when possible.
- Split commits by intent: aspect changes, input/lock changes, docs/options refresh.
- Do not keep unrelated lockfile churn unless the user asked for input updates.
