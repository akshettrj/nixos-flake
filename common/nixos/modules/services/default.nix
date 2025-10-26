{...}: {
  imports = [
    ./nginx.nix
    ./openssh.nix
    ./openvpn.nix
    ./pipewire.nix
    ./printing.nix
    ./self_hosted
    ./tailscale.nix
    ./telegram_bot_api.nix
    ./virtualisation.nix
  ];
}
