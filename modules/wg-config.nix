{ config
, lib
, pkgs
, ...
}: rec {
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
      # dependency on private-key to ensure use of newly generated key
      ls ${private-key}
      cat /etc/opt/ivpn/mutable/settings.json ${pkgs.jq}/bin/jq -r '.Session.WGPublicKey' $out
    '';
}
