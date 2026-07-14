---
name: nixos-configuration
description: Manage the dendritic NixOS config and Home Manager flake, not any other nix flake. Use when editing hosts, aspects, flake inputs, options, templates, docs/options.json, validation commands, or repo-local AI skills in this dendritic-nix repository.
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
- `oracleamd1ca`
- `oracleamperehyd`
- `raspi`

## Dendritic Rules

- Put option declarations beside the module that consumes them.
- Keep old buckets out of new work; name files by capability, not by legacy source path.
- Keep core thin. Move feature behavior into an aspect.
- If a feature has both NixOS and Home Manager wiring, keep both under the same aspect.
- Preserve behavior unless the user explicitly asks for modernization.
- Do not edit `vendor/` except for comparison.
- When adding or enabling a new desktop/user-facing application, check whether it
  has colors/theme settings that can consume `biryani.theming.palette`. If it
  can, try to add a `biryani.theming.matugen.integrations.<app>.enable` toggle
  and default it on with a static-palette fallback. Include browsers when they
  have declarative theme/color hooks, while avoiding brittle profile mutation.
- Prefer app-native color formats over raw hex. Some TUI apps, notably
  `ncmpcpp`, only accept terminal color names or indices; use terminal palette
  colors there so matugen flows through the terminal instead of emitting invalid
  `#rrggbb` values.
- Avoid broad GTK CSS selectors that paint every `window` or `.background`.
  They can break transparency for GTK layer-shell/terminal apps such as SwayNC
  and Ghostty. Use app-specific CSS or narrow widget selectors when possible.

## The NixOS ↔ Home `biryani` Bridge (read before adding any option)

`biryani.*` options are declared **twice**, once per module graph, and the two
graphs do not share option definitions. A Home Manager module cannot read an
option that only exists on the NixOS graph — it fails with
`error: attribute '<name>' missing`. The wiring:

1. **Declaration (once, shared).** Put the `options.biryani.*` declaration in its
   own small file and `imports` it into **both** graphs — the NixOS aggregator
   (`aspects/desktop/options.nix`) so hosts can set values, and the home consumer
   module so it can read them. Do **not** re-type the schema in two files.
   Example: `aspects/desktop/environments/wayland/vnc-options.nix` is imported by
   both `aspects/desktop/options.nix` and `.../wayland/vnc.nix`. (An options-only
   file is safe to import into either graph; a file that also defines `config`
   with `home.*`/`systemd.user.*` is home-only, so split options out.)
2. **Forwarding (one line).** `aspects/<feature>/home-bridge.nix` copies the value
   from the NixOS `biryani` special-arg into the home graph's `config.biryani.*`
   (the home config receives NixOS `config.biryani` as the `biryani` module arg,
   wired in `aspects/core/home-maker.nix`). This is value forwarding, not schema
   duplication, and is required by the two-graph design.

So a **Home Manager**-consumed option needs: one shared declaration file imported
into both graphs, plus the `home-bridge.nix` forward line. Miss the home-graph
import or the forward and you get `attribute '<name>' missing`. A NixOS-only
option needs only the declaration, imported into the NixOS graph.

> Older aspects instead re-declare the same option in both `options.nix` (strict
> `enum` types) and a home module like `environments/default.nix` (looser `str`
> types). Prefer the shared-file approach above for new work; only re-declare when
> the two graphs genuinely need different types.

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

When validating changes:

- `git add` any **new** file before running `.#` flake checks. Flakes only see
  git-tracked files, so a new aspect module evaluates as
  `Path '<file>' ... is not tracked by Git` until staged (intent-to-add with
  `git add -N` is enough). The `--impure` `getFlake (toString ./.)` and
  `nix eval --file` forms read the dirty working tree and do not need this.
- Prefer no-build/eval checks first. Do not build broad Home Manager or NixOS
  activation/system derivations unless the user explicitly asks; they can fetch
  or build large dependency closures.
- For generated Home Manager files, inspect the config text directly with
  `nix eval` instead of building the activation package. Example:
  ```sh
  nix eval --impure --raw --expr '(builtins.getFlake (toString ./.)).homeConfigurations."akshettrj@alienrj".config.xdg.configFile."hypr/hyprland.lua".text'
  ```
- If a build is truly needed, keep it narrow to the affected attribute and ask
  before running it.

When the user explicitly requests builds:

- Use `nom` and 16 jobs/cores:
  ```sh
  nom build <attr> --option max-jobs 16 --cores 16
  ```

## No-Build Checks

Use these before any build, and often as the final validation for small module
or generated-config changes:

```sh
nix eval --raw .#nixosConfigurations.alienrj.config.networking.hostName
nix eval --raw .#nixosConfigurations.oracleamd1ca.config.networking.hostName
nix eval --raw .#nixosConfigurations.oracleamperehyd.config.networking.hostName
nix eval --raw .#nixosConfigurations.raspi.config.networking.hostName
nix eval --raw .#homeConfigurations.'akshettrj@alienrj'.config.home.username
nix eval --raw .#homeConfigurations.'akshettrj@oracleamd1ca'.config.home.username
nix eval --raw .#homeConfigurations.'akshettrj@oracleamperehyd'.config.home.username
nix eval --raw .#homeConfigurations.'akshettrj@raspi'.config.home.username
```

## Commit Hygiene

- Keep build validation separate from broad structural edits when possible.
- Split commits by intent: aspect changes, input/lock changes, docs/options refresh.
- Do not keep unrelated lockfile churn unless the user asked for input updates.
