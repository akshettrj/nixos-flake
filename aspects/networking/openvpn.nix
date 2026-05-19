{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.services.openvpn = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable the OpenVPN server configuration.";
        };

        port = lib.mkOption {
            type = lib.types.port;
            example = 1194;
            description = "Port used by the OpenVPN server.";
        };

        protocol = lib.mkOption {
            type = lib.types.enum [
                "udp"
                "tcp"
            ];
            description = "Transport protocol used by the OpenVPN server.";
        };

        network = lib.mkOption {
            type = lib.types.str;
            example = "10.8.0.0/24";
            description = "VPN subnet in CIDR notation.";
        };

        dns = lib.mkOption {
            type = lib.types.enum [
                "system"
                "cloudflare"
                "quad9"
                "unbound"
            ];
            description = "DNS resolver profile pushed to OpenVPN clients.";
        };

        enable_unbound = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Unbound as a local resolver for OpenVPN clients.";
        };

        cipher = lib.mkOption {
            type = lib.types.str;
            example = "AES-256-GCM";
            description = "Cipher configured for the OpenVPN server.";
        };

        ca_dir = lib.mkOption {
            type = lib.types.path;
            example = "/var/lib/openvpn/pki";
            description = "Directory where OpenVPN EasyRSA PKI material is stored.";
        };

        server_name = lib.mkOption {
            type = lib.types.str;
            example = "server";
            description = "OpenVPN server instance name.";
        };

        clients = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "Client certificate names to generate.";
        };

        allow_duplicate_cns = lib.mkOption {
            type = lib.types.bool;
            description = "Allow multiple concurrent connections using the same client certificate.";
        };
    };

    config =
        let
            guessExternalInterface =
                interfaces:
                let
                    physicalIfaces = builtins.filter (
                        iface:
                        !(builtins.elem iface [
                            "lo"
                            "docker0"
                            "br0"
                            "tailscale0"
                            "virbr0"
                        ])
                    ) (builtins.attrNames interfaces);
                in
                (if physicalIfaces != [ ] then builtins.head physicalIfaces else null);
            biryani_openvpn = config.biryani.services.openvpn;
        in
        lib.mkIf biryani_openvpn.enable {
            networking.firewall = {
                allowedUDPPorts = lib.mkIf (biryani_openvpn.protocol == "udp") [ biryani_openvpn.port ];
                allowedTCPPorts = lib.mkIf (biryani_openvpn.protocol == "tcp") [ biryani_openvpn.port ];
            };

            networking.nat.enable = true;
            networking.nat.internalInterfaces = [ "tun0" ];
            networking.nat.externalInterface = lib.mkDefault (
                guessExternalInterface config.networking.interfaces
            );

            boot.kernel.sysctl."net.ipv4.ip_forward" = "1";

            environment.systemPackages = [
                pkgs.openvpn
                pkgs.easyrsa
            ];

            services.unbound = lib.mkIf biryani_openvpn.enable_unbound {
                enable = true;
                settings = {
                    server = {
                        interface = [
                            "127.0.0.1"
                            "10.8.0.1"
                        ];
                        access-control = [
                            "127.0.0.0/8 allow"
                            "10.8.0.0/24 allow"
                        ];
                        hide-identity = "yes";
                        hide-version = "yes";
                        prefetch = "yes";
                    };
                };
            };

            systemd.services.easyrsa-init = {
                description = "Initialize EasyRSA PKI for OpenVPN";
                after = [ "network-online.target" ];
                wants = [ "network-online.target" ];
                before = [ "openvpn-${biryani_openvpn.server_name}.service" ];
                wantedBy = [ "multi-user.target" ];

                serviceConfig = {
                    Type = "oneshot";
                    Environment = "PATH=${
                        lib.makeBinPath (
                            with pkgs;
                            [
                                easyrsa
                                openssl
                                gawk
                                coreutils
                                bash
                                gnugrep
                                gnused
                                which
                                bc
                            ]
                        )
                    }";
                    ExecStart = pkgs.writeShellScript "init-easyrsa" ''
                        set -eux
                        export EASYRSA_BATCH=1
                        umask 077
                        mkdir -p ${biryani_openvpn.ca_dir}
                        cd ${biryani_openvpn.ca_dir}
                        if [ ! -f pki/ca.crt ]; then
                          easyrsa init-pki
                          echo | easyrsa build-ca nopass
                          easyrsa gen-dh
                          easyrsa build-server-full ${biryani_openvpn.server_name} nopass
                          easyrsa gen-crl
                          chmod 644 pki/crl.pem || true
                        fi
                    '';
                };
            };

            # Generate client certs + .ovpn files
            systemd.services."easyrsa-generate-clients" = {
                description = "Generate client certificates and .ovpn files";
                after = [ "easyrsa-init.service" ];
                before = [ "openvpn-${biryani_openvpn.server_name}.service" ];
                wantedBy = [ "multi-user.target" ];
                serviceConfig =
                    let
                        clientDir = "${biryani_openvpn.ca_dir}/clients";
                    in
                    {
                        Type = "oneshot";
                        Environment = "PATH=${
                            lib.makeBinPath (
                                with pkgs;
                                [
                                    easyrsa
                                    openssl
                                    gawk
                                    coreutils
                                    bash
                                    gnugrep
                                    gnused
                                    which
                                    bc
                                    hostname
                                ]
                            )
                        }";
                        ExecStart = pkgs.writeShellScript "generate-clients" ''
                                        set -eux
                                        export EASYRSA_BATCH=1
                                        umask 077
                                        mkdir -p ${clientDir}
                                        chmod 700 ${clientDir}

                                        cd ${biryani_openvpn.ca_dir}

                                        for client in ${lib.concatStringsSep " " (biryani_openvpn.clients)}; do
                                          if [ ! -f pki/issued/$client.crt ]; then
                                            ${pkgs.easyrsa}/bin/easyrsa build-client-full "$client" nopass
                                          fi

                                          cat > ${clientDir}/$client.ovpn <<EOF
                            client
                            dev tun
                            proto ${biryani_openvpn.protocol}
                            remote $(hostname -f) ${toString biryani_openvpn.port}
                            resolv-retry infinite
                            nobind
                            persist-key
                            persist-tun
                            remote-cert-tls server
                            cipher ${biryani_openvpn.cipher}
                            verb 3

                            <ca>
                            $(cat ${biryani_openvpn.ca_dir}/pki/ca.crt)
                            </ca>
                            <cert>
                            $(cat ${biryani_openvpn.ca_dir}/pki/issued/$client.crt)
                            </cert>
                            <key>
                            $(cat ${biryani_openvpn.ca_dir}/pki/private/$client.key)
                            </key>

                            $(if [ "${biryani_openvpn.dns}" = "cloudflare" ]; then
                              echo 'dhcp-option DNS 1.1.1.1'
                              echo 'dhcp-option DNS 1.0.0.1'
                            elif [ "${biryani_openvpn.dns}" = "quad9" ]; then
                              echo 'dhcp-option DNS 9.9.9.9'
                              echo 'dhcp-option DNS 149.112.112.112'
                            elif [ "${biryani_openvpn.dns}" = "unbound" ]; then
                              echo 'dhcp-option DNS 10.8.0.1'
                            fi)
                            EOF
                                        done
                        '';
                    };
            };

            services.openvpn.servers.${biryani_openvpn.server_name} =
                let
                    networkParts = builtins.split "/" biryani_openvpn.network;
                    networkAddress = lib.elemAt networkParts 0;
                    prefixLength = lib.elemAt networkParts 2;
                    networkMask = lib.optionalString true (
                        if prefixLength == "24" then
                            "255.255.255.0"
                        else if prefixLength == "16" then
                            "255.255.0.0"
                        else if prefixLength == "8" then
                            "255.0.0.0"
                        else
                            abort "Unsupported network prefix: ${prefixLength}"
                    );
                in
                {
                    config = ''
                        port ${toString biryani_openvpn.port}
                        proto ${biryani_openvpn.protocol}
                        dev tun
                        ${lib.optionalString biryani_openvpn.allow_duplicate_cns "duplicate-cn"}
                        ca ${biryani_openvpn.ca_dir}/pki/ca.crt
                        cert ${biryani_openvpn.ca_dir}/pki/issued/${biryani_openvpn.server_name}.crt
                        key ${biryani_openvpn.ca_dir}/pki/private/${biryani_openvpn.server_name}.key
                        dh ${biryani_openvpn.ca_dir}/pki/dh.pem
                        server ${networkAddress} ${networkMask}
                        topology subnet
                        push "redirect-gateway def1 bypass-dhcp"
                        ${lib.optionalString (biryani_openvpn.dns == "cloudflare") ''
                            push "dhcp-option DNS 1.1.1.1"
                            push "dhcp-option DNS 1.0.0.1"
                        ''}
                        ${lib.optionalString (biryani_openvpn.dns == "quad9") ''
                            push "dhcp-option DNS 9.9.9.9"
                            push "dhcp-option DNS 149.112.112.112"
                        ''}
                        ${lib.optionalString (biryani_openvpn.dns == "unbound") ''
                            push "dhcp-option DNS 10.8.0.1"
                        ''}
                        keepalive 10 120
                        cipher ${biryani_openvpn.cipher}
                        user nobody
                        group nogroup
                        persist-key
                        persist-tun
                        status /var/log/openvpn-status.log
                        verb 3
                    '';
                };
        };
}
