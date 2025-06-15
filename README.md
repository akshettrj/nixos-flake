# NIXOS CONFIGURATION

## BUILDING FOR ANOTHER HOST

```sh
nixos-rebuild (boot|build|switch) --target-host user@remote_host --use-remote-sudo --flake .#raspi
```



## TODOs

- [ ] Make graphics module's 32 bit support configurable
- [ ] Make blurs in a lot of programs configurable for raspi
