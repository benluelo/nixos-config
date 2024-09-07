{ pkgs, ... }:
{
  nix = {
    # # nixbuild
    # distributedbuilds = true;
    # buildmachines = [
    #   {
    #     hostname = "eu.nixbuild.net";
    #     system = "x86_64-linux";
    #     maxjobs = 100;
    #     supportedfeatures = [ "benchmark" "big-parallel" ];
    #   }
    # ];
    package = pkgs.nixVersions.latest;
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
