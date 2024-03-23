{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-fmt = {
      url = "github:nix-community/nixpkgs-fmt";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    helix = { url = "github:helix-editor/helix"; };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-darwin, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;

        config = { allowUnfree = true; };
      };

      lib = nixpkgs.lib;

      darwinConfiguration = { pkgs, ... }: {
        imports = [
          ./modules/fonts.nix
        ];

        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment = {
          systemPackages = with pkgs; [
            tree
            lazygit
            git
            helix
          ];
          variables = {
            EDITOR = "hx";
          };
        };

        homebrew = {
          enable = true;
          onActivation = {
            cleanup = "zap";
            autoUpdate = false;
            upgrade = false;
          };
          casks = [
            "steam"
            "1password"
            "1password-cli"
          ];
        };

        users.users.ben = {
          home = "/Users/ben";
          shell = pkgs.bash;
        };

        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        # nix.package = pkgs.nix;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.bash = {
          # default shell on catalina
          enable = true;
          enableCompletion = true;
          # copied from https://github.com/NixOS/nixpkgs/blob/56528ee42526794d413d6f244648aaee4a7b56c0/nixos/modules/programs/bash/bash.nix#L78
          interactiveShellInit = ''
            # Provide a nice prompt if the terminal supports it.
            if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
              PROMPT_COLOR="1;31m"
              ((UID)) && PROMPT_COLOR="1;32m"
              if [ -n "$INSIDE_EMACS" ]; then
                # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
                PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
              else
                PS1="\n\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
              fi
              if test "$TERM" = "xterm"; then
                PS1="\[\033]2;\h:\u:\w\007\]$PS1"
              fi
            fi
          '';
        };
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 4;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
        nixpkgs.config.allowUnfree = true;
      };

      moduleArgs = {
        signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGl4qAz9DcqO1JOSBWIatv79lHLZIfy+x6ZP2thMviI/";
      };

      hm = {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.ben = {
            nixpkgs.overlays = pkgs.lib.optionals pkgs.stdenv.isLinux [ (import ./pkgs) ];
            imports = [
              ./home-modules/git.nix
              ./home-modules/helix.nix
              ./home-modules/misc.nix
              ./home-modules/kitty.nix
              # ./home-modules/gdlauncher.nix
            ];
          };

          extraSpecialArgs = { inherit inputs; } // moduleArgs;
        };
      };
    in
    {
      formatter.${system} = inputs.nixpkgs-fmt.defaultPackage.${system};
      formatter."aarch64-linux" = inputs.nixpkgs-fmt.defaultPackage."aarch64-linux";

      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;

          modules = [
            ./modules/configuration.nix
            ./modules/networking.nix
            ./modules/users.nix
            ./modules/nix.nix
            home-manager.nixosModules.home-manager
            hm
          ];
        };
        orb = lib.nixosSystem {
          system = "aarch64-linux";

          modules = [
            ./orb-modules/configuration.nix
            ./modules/users.nix
            ./modules/nix.nix
            home-manager.nixosModules.home-manager
            hm
            {
              _module.args = moduleArgs;
            }
          ];
        };
      };

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#mac
      darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
        modules = [
          darwinConfiguration
          home-manager.darwinModules.home-manager
          hm
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew nder the default prefix
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # User owning the Homebrew prefix
              user = "ben";

              # Optional: Declarative tap management
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };

              # Optional: Enable fully-declarative tap management
              #
              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."mac".pkgs;
    };
}
