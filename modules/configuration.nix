# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config
, lib
, pkgs
, ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./fonts.nix
  ];

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  virtualisation.docker.enable = true;

  hardware.ledger.enable = true;

  programs.ssh.extraConfig = ''
    Host eu.nixbuild.net
      PubkeyAcceptedKeyTypes ssh-ed25519
      ServerAliveInterval 60
      IPQoS throughput
      IdentityFile /path/to/your/private/key
  '';

  programs.ssh.knownHosts = {
    nixbuild = {
      hostNames = [ "eu.nixbuild.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    };
  };

  nix = {
    # nixbuild
    distributedBuilds = true;
    buildMachines = [
      { hostName = "eu.nixbuild.net";
        system = "x86_64-linux";
        maxJobs = 100;
        supportedFeatures = [ "benchmark" "big-parallel" ];
      }

    ];
    package = pkgs.nixUnstable;
    settings = {
      trusted-users = [ "root" "ben" ];
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://union.cachix.org"
        # "https://pre-commit-hooks.cachix.org"
        # "https://cosmos.cachix.org"
      ];
      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://union.cachix.org"
        # "https://pre-commit-hooks.cachix.org"
        # "https://cosmos.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "union.cachix.org-1:TV9o8jexzNVbM1VNBOq9fu8NK+hL6ZhOyOh0quATy+M="
        # "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
        # "cosmos.cachix.org-1:T5U9yg6u2kM48qAOXHO/ayhO8IWFnv0LOhNcq0yKuR8="
      ];
    };
  };

  # Bootloader.
  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    loader = {
      systemd-boot.enable = true;

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };

  # Set your time zone.
  time.timeZone = null;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  services = {
    grafana = {
      enable = true;
      settings = {
        server = {
          # Listening Address
          http_addr = "127.0.0.1";
          # and Port
          http_port = 3000;
          # # Grafana needs to know on which domain and URL it's running
          # domain = "your.domain";
          # root_url = "https://your.domain/grafana/"; # Not needed if it is `https://your.domain/`
        };
      };
    };
    postgresql = let
      # The postgresql pkgs has to be taken from the
      # postgresql package used, so the extensions
      # are built for the correct postgresql version.
      postgresqlPackages = config.services.postgresql.package.pkgs;
    in {
      # https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
      authentication = pkgs.lib.mkOverride 10 ''
        #type database  user  auth-method
        local all       all   trust
        #type database  user  address     auth-method
        host  all       all   all         md5
      '';
      enable = true;
      extraPlugins = [ postgresqlPackages.timescaledb ];
      settings.shared_preload_libraries = "timescaledb";
    };

    mysql = {
      enable = true;
      package = pkgs.mysql80;
    };

    udev = {
      enable = true;
      extraRules = let
        # UB Funkeys
        MegaByte = {
          idVendor = "0e4c";
          idProduct = "7288";
        };
      in ''
        SUBSYSTEM=="usb",        ATTRS{idVendor}=="${MegaByte.idVendor}", ATTRS{idProduct}=="${MegaByte.idProduct}", MODE="0666"
        SUBSYSTEM=="usb_device", ATTRS{idVendor}=="${MegaByte.idVendor}", ATTRS{idProduct}=="${MegaByte.idProduct}", MODE="0666"
      '';
    };

    blueman.enable = true;

    ivpn.enable = true;

    xserver = {
      # # Load nvidia driver for Xorg and Wayland
      # videoDrivers = ["nvidia"];
      # Enable the X11 windowing system.
      enable = true;

      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      # Configure keymap in X11
      layout = "us";
      xkbVariant = "";
    };

    # Enable CUPS to print documents.
    printing.enable = true;
  };

  hardware.system76 = {
    enableAll = true;
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.

  programs.nix-ld.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "openssl-1.1.1t"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gnumake
    cntr
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # wget
    ivpn
    ivpn-service
    tree
    lazygit
    git
    helix
    docker
    docker-client
    ((import ../pkgs/gdlauncher.nix) pkgs)
    # ((import ../pkgs/modrinth-app.nix) pkgs)
  ];

  environment.variables = {
    EDITOR = "hx";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  # system.nssDatabases.hosts = lib.mkForce [
  #   "files" "mdns4_minimal [NOTFOUND=return]" "dns"
  #   # "resolve [!UNAVAIL=return]"
  #   # "dns"
  #   # "mymachines"
  #   # "files"
  #   # "myhostname"
  #  ];
}
