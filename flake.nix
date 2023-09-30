{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-fmt = {
      url = "github:nix-community/nixpkgs-fmt";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = { url = "github:helix-editor/helix"; };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;

        config = { allowUnfree = true; };
      };

      lib = nixpkgs.lib;
    in
    {
      formatter.${system} = inputs.nixpkgs-fmt.defaultPackage.${system};

      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;

          modules = [
            ./modules/configuration.nix
            ./modules/networking.nix
            # ./modules/wg-config.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.ben = {
                  nixpkgs.overlays = [ (import ./pkgs) ];
                  imports = [
                    ./home-modules/git.nix
                    ./home-modules/helix.nix
                    ./home-modules/misc.nix
                    ./home-modules/kitty.nix
                    # ./home-modules/gdlauncher.nix
                  ];
                };

                extraSpecialArgs = { inherit inputs; };
              };

              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
            }
          ];
        };
      };
    };
}
