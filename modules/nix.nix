{ pkgs, ... }:
{
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
      ];
      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://union.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "union.cachix.org-1:TV9o8jexzNVbM1VNBOq9fu8NK+hL6ZhOyOh0quATy+M="
      ];
    };
  };
}
