---
name: nixos-configuration
description: "understanding the nixos-configuration & home-manager setup"
---

# NixOS Setup

1. We use a flake based setup. The repository is generally located at `~/.config/nixos-flake`.
2. The flake contains outputs for both: NixOS & Home Manager for all of the target machines and are
    generated dynamically.
3. The `options.nix` file contains custom options which are used in both NixOS & HM to configure target
    machine specific settings.
4. Different target machines are present under the `hosts` directory.
5. The `common` directory contains modules for NixOS and Home Manager which consume the custom options.
