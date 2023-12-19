{ pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "benluelo";
    userEmail = "git@luelo.dev";
    lfs.enable = true;

    signing = {
      signByDefault = true;
      key = "";
    };

    extraConfig = {
      user = {
        signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGl4qAz9DcqO1JOSBWIatv79lHLZIfy+x6ZP2thMviI/";
      };
      color.ui = true;
      github.user = "benluelo";
      url."git@github.com:".insteadOf = "https://github.com/";
      # core.ignorecase = false;
      gpg = {
        format = "ssh";
        # TODO: Figure out how this works on linux
        ssh.program = if pkgs.stdenv.isDarwin then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign" else "${pkgs._1password-gui}";
      };
      commit.gpgsign = true;
    };
  };
}
