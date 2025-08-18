{ pkgs, signingkey, ... }:
{
  users.users.ben = {
    isNormalUser = true;
    description = "ben";
    extraGroups = [ "networkmanager" "wheel" "docker" "plugdev" ];
    packages = with pkgs; [
      lazygit
      # ledger-live-desktop
      # linuxKernel.packages.${kernel.version}.system76-power
      # linuxKernel.packages.${kernel.version}.system76
      # linuxKernel.packages.${kernel.version}.system76
      # dbeaver
      # signal-desktop-beta
      # firefox
      # discord
      _1password
      # easyeffects
      # spotify
      # element-desktop
    ];
    hashedPassword = "$y$j9T$Aq8RNJib3WzFRsXFoN2xA0$O84qbGIWeE0CLDYb0VpfKOUfcwmPPf/tWNoomAUUEx5";
    openssh.authorizedKeys.keys = [
      signingkey
    ];
  };
}
