{ config
, lib
, pkgs
, ...
}:
let
  privatekey = pkgs.runCommand
    { }
    ''
      ${pkgs.ivpn}/bin/ivpn wgkeys -regenerate
      cat /etc/opt/ivpn/mutable/settings.json ${pkgs.jq}/bin/jq -r '.Session.WGPrivateKey' $out
      chmod 600 $out
    '';
  publickey = pkgs.runCommand
    { }
    ''
      # dependency on privatekey to ensure use of newly generated key
      ls ${privatekey}
      cat /etc/opt/ivpn/mutable/settings.json ${pkgs.jq}/bin/jq -r '.Session.WGPublicKey' $out
    '';
in
{
  networking = {
    hostName = "nixos"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager.enable = true;
    nameservers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
    # useDHCP = true;

    firewall = {
      allowedUDPPorts = [ 51820 ]; # Clients and peers can use the same port, see listenport
    };

    # Enable WireGuard
    # wireguard.interfaces = {
    #   # "wg0" is the network interface name. You can name the interface arbitrarily.
    #   wg0 = {
    #     # Determines the IP address and subnet of the client's end of the tunnel interface.
    #     ips = [ "10.100.0.2/24" ];
    #     listenPort = 51820; # to match firewall allowedUDPPorts (without this wg uses random port numbers)

    #     # Path to the private key file.
    #     #
    #     # Note: The private key can also be included inline via the privateKey option,
    #     # but this makes the private key world-readable; thus, using privateKeyFile is
    #     # recommended.
    #     privateKeyFile = "${privatekey}";

    #     peers = [
    #       # For a client configuration, one peer entry for the server will suffice.

    #       {
    #         # Public key of the server (not a file path).
    #         publicKey =  builtins.readFile "${publickey}";

    #         # Forward all the traffic via VPN.
    #         allowedIPs = [ "0.0.0.0/0" ];
    #         # Or forward only particular subnets
    #         #allowedIPs = [ "10.100.0.1" "91.108.12.0/22" ];

    #         # Set this to the server IP and port.
    #         endpoint = "{endpoint}:51820"; # ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577

    #         # Send keepalives every 25 seconds. Important to keep NAT tables alive.
    #         persistentKeepalive = 25;
    #       }
    #     ];
    #   };
    # };
  };

  systemd.user.services.ivpn-connect = {
    description = "connect to the fastest ivpn server.";
    after = [ "ivpn-service.service" ];
    wantedBy = [ "default.target" ];
    script = ''
      ${pkgs.ivpn}/bin/ivpn autoconnect -on_launch on

      STATUS=$(${pkgs.ivpn}/bin/ivpn status | head -n 1 | cut -d ":" -f2 | tr -d " ")

      case $STATUS in
        "CONNECTED")
          echo "already connected; disconnecting..."
          ${pkgs.ivpn}/bin/ivpn disconnect
          ;;
        "DISCONNECTED")
          echo "already disconnected"
          ;;
        *)
          echo "unknown ivpn status: $STATUS"
          exit 1
          ;;
      esac

      FASTEST=$(${pkgs.ivpn}/bin/ivpn servers -ping -p wg | tail -1 | cut -d "|" -f2 | tr -d ' ')

      echo "fastest server is $FASTEST"

      ${pkgs.ivpn}/bin/ivpn connect $FASTEST

      echo "successfully connected to $FASTEST"
    '';
  };
}
