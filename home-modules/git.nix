{ ... }: {
  programs.git = {
    enable = true;
    userName = "benluelo";
    userEmail = "git@luelo.dev";
    lfs.enable = true;

    signing = {
      signByDefault = true;
      key = "~/.ssh/id_ecdsa_sk.pub";
    };

    extraConfig = {
      color.ui = true;
      github.user = "benluelo";
      url."git@github.com:".insteadOf = "https://github.com/";
      gpg.format = "ssh";
      commit.gpgsign = true;
    };
  };
}
