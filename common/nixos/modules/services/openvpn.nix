{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    guessExternalInterface = interfaces: let
      physicalIfaces = builtins.filter (iface: !(builtins.elem iface ["lo" "docker0" "br0" "tailscale0" "virbr0"])) (builtins.attrNames interfaces);
    in (
      if physicalIfaces != []
      then builtins.head physicalIfaces
      else null
    );
    pro_openvpn = config.propheci.services.openvpn;
  in
    lib.mkIf pro_openvpn.enable {
      networking.firewall = {
        allowedUDPPorts = lib.mkIf (pro_openvpn.protocol == "udp") [pro_openvpn.port];
        allowedTCPPorts = lib.mkIf (pro_openvpn.protocol == "tcp") [pro_openvpn.port];
      };

      networking.nat.enable = true;
      networking.nat.internalInterfaces = ["tun0"];
      networking.nat.externalInterface = lib.mkDefault (guessExternalInterface config.networking.interfaces);

      boot.kernel.sysctl."net.ipv4.ip_forward" = true;

      environment.systemPackages = [pkgs.openvpn pkgs.easy-rsa];

      services.unbound = lib.mkIf pro_openvpn.enable_unbound {
        enable = true;
        settings = {
          server = {
            interface = ["127.0.0.1" "10.8.0.1"];
            access-control = ["127.0.0.0/8 allow" "10.8.0.0/24 allow"];
            hide-identity = "yes";
            hide-version = "yes";
            prefetch = "yes";
          };
        };
      };

      systemd.services.easyrsa-init = {
        description = "Initialize EasyRSA PKI for OpenVPN";
        after = ["networking.target"];
        before = ["openvpn-server@server.service"];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "init-easyrsa" ''
            set -eux
            mkdir -p ${pro_openvpn.ca_dir}
            cd ${pro_openvpn.ca_dir}
            if [ ! -f pki/ca.crt ]; then
              ${pkgs.easy-rsa}/bin/easyrsa init-pki
              echo | ${pkgs.easy-rsa}/bin/easyrsa build-ca nopass
              ${pkgs.easy-rsa}/bin/easyrsa gen-dh
              ${pkgs.easy-rsa}/bin/easyrsa build-server-full ${pro_openvpn.server_name} nopass
              ${pkgs.easy-rsa}/bin/easyrsa gen-crl
            fi
          '';
        };
      };

      # Generate client certs + .ovpn files
      systemd.services."easyrsa-generate-clients" = {
        description = "Generate client certificates and .ovpn files";
        after = ["easyrsa-init.service"];
        wantedBy = ["multi-user.target"];
        serviceConfig = let
          clientDir = "${pro_openvpn.ca_dir}/clients";
        in {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "generate-clients" ''
                      set -eux
                      mkdir -p ${clientDir}

                      cd ${pro_openvpn.ca_dir}

                      for client in ${lib.concatStringsSep " " (pro_openvpn.clients)}; do
                        if [ ! -f pki/issued/$client.crt ]; then
                          ${pkgs.easy-rsa}/bin/easyrsa build-client-full "$client" nopass
                        fi

                        cat > ${clientDir}/$client.ovpn <<EOF
client
dev tun
proto ${pro_openvpn.protocol}
remote $(hostname -f) ${toString pro_openvpn.port}
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher ${pro_openvpn.cipher}
verb 3

<ca>
$(cat ${pro_openvpn.ca_dir}/pki/ca.crt)
</ca>
<cert>
$(cat ${pro_openvpn.ca_dir}/pki/issued/$client.crt)
</cert>
<key>
$(cat ${pro_openvpn.ca_dir}/pki/private/$client.key)
</key>
<dh>
$(cat ${pro_openvpn.ca_dir}/pki/dh.pem)
</dh>

$(if [ "${pro_openvpn.dns}" = "cloudflare" ]; then
  echo 'dhcp-option DNS 1.1.1.1'
  echo 'dhcp-option DNS 1.0.0.1'
elif [ "${pro_openvpn.dns}" = "quad9" ]; then
  echo 'dhcp-option DNS 9.9.9.9'
  echo 'dhcp-option DNS 149.112.112.112'
elif [ "${pro_openvpn.dns}" = "unbound" ]; then
  echo 'dhcp-option DNS 10.8.0.1'
fi)
EOF
                      done
          '';
        };
      };


    services.openvpn.servers.${pro_openvpn.server_name} = {
      enable = true;
      config = ''
        port ${toString pro_openvpn.port}
        proto ${pro_openvpn.proto}
        dev tun
        ${lib.optionalString pro_openvpn.allow_duplicate_cns "duplicate-cn"}
        ca ${pro_openvpn.ca_dir}/pki/ca.crt
        cert ${pro_openvpn.ca_dir}/pki/issued/${pro_openvpn.server_name}.crt
        key ${pro_openvpn.ca_dir}/pki/private/${pro_openvpn.server_name}.key
        dh ${pro_openvpn.ca_dir}/pki/dh.pem
        server ${pro_openvpn.network}
        topology subnet
        push "redirect-gateway def1 bypass-dhcp"
        ${lib.optionalString (pro_openvpn.dns == "cloudflare") ''
          push "dhcp-option DNS 1.1.1.1"
          push "dhcp-option DNS 1.0.0.1"
        ''}
        ${lib.optionalString (pro_openvpn.dns == "quad9") ''
          push "dhcp-option DNS 9.9.9.9"
          push "dhcp-option DNS 149.112.112.112"
        ''}
        ${lib.optionalString (pro_openvpn.dns == "unbound") ''
          push "dhcp-option DNS 10.8.0.1"
        ''}
        keepalive 10 120
        cipher ${pro_openvpn.cipher}
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
