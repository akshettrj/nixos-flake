# NIXOS CONFIGURATION

## BUILDING FOR ANOTHER HOST

```sh
nixos-rebuild (boot|build|switch) --target-host <user>@<remote_host> --sudo --flake .#<target_configuration>
```

## INSTALLING REMOTELY USING NIXOS-ANYWHERE

- For Oracle's AMD free tier, start with Ubuntu Minimal OS as image.
- Then create `disk-config.nix` similar to others
- The `hardware-configuration.nix` file can be an issue. Output it to some other path and edit manually.

```sh
nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config <path_for_hardware_config_file> --flake .#<configuration> --target-host <user>@<remote_host> -i <ssh_key_path>
```

## INSTALLING AND ACTIVATING HOME-MANAGER CONFIGURATIONS REMOTELY

```sh
nix build .#homeConfigurations.<user>@<server>.activationPackage \
  && nix copy --to ssh://<user>@<server> ./result \
  && ssh <user>@<server> $(readlink -f result)/activate
```

## TODOs

- [ ] Make graphics module's 32 bit support configurable
- [ ] Make blurs in a lot of programs configurable for raspi
