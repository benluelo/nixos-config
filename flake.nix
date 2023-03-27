{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {url = "github:kamadorueda/alejandra/3.0.0";
    inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;

        config = { allowUnfree = true; };
      };

      lib = nixpkgs.lib;
    in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;

        modules = [
          ./modules/configuration.nix
          ./modules/networking.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.ben = {imports = [ ./home-modules/git.nix ./home-modules/misc.nix];};
            };

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };
  };
}
