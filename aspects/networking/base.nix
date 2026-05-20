{
    config,
    lib,
    pkgs,
    ...
}:
{
    options =
        let
            inherit (lib) mkOption types;
        in
        {
            biryani = {
                system.hostname = mkOption {
                    type = types.str;
                    example = "alienrj";
                    description = "Hostname assigned to this NixOS system.";
                };

                services.firewall = {
                    enable = mkOption {
                        type = types.bool;
                        description = "Enable the NixOS firewall with the configured allowed ports.";
                    };

                    tcp_ports = mkOption {
                        type = types.listOf types.port;
                        example = [ 22 ];
                        description = "TCP ports allowed through the host firewall.";
                    };

                    udp_ports = mkOption {
                        type = types.listOf types.port;
                        example = [ 6969 ];
                        description = "UDP ports allowed through the host firewall.";
                    };
                };
            };
        };

    config =
        let
            biryani_system = config.biryani.system;
            biryani_services = config.biryani.services;
        in
        {
            networking.hostName = biryani_system.hostname;
            networking.networkmanager = {
                enable = true;
                plugins = [ pkgs.networkmanager-openvpn ];
            };
            networking.firewall = lib.mkIf biryani_services.firewall.enable {
                enable = true;
                trustedInterfaces = [ "tailscale0" ];
                allowedUDPPorts = [ config.services.tailscale.port ] ++ biryani_services.firewall.udp_ports;
                allowedTCPPorts = [ config.services.tailscale.port ] ++ biryani_services.firewall.tcp_ports;
            };
            networking.nameservers = [
                "1.1.1.1"
                "1.0.0.1"
            ];
        };
}
