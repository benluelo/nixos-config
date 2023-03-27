{...}: {
  programs.git = {
    enable = true;
    userName = "benluelo";
    userEmail = "benluelo@hotmail.com";
    lfs.enable = true;

    signing = {
      signByDefault = true;
      key = "~/.ssh/id_ecdsa_sk.pub";
    };

    extraConfig = {
      color.ui = true;
      github.user = "benluelo";
      gpg.format = "ssh";
      commit.gpgsign = true;
    };
  };
}
