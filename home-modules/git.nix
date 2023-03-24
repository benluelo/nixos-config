{ ... }:
{
  programs.git = {
    enable = true;
    userName = "benluelo";
    userEmail = "benluelo@hotmail.com";
    lfs.enable = true;
    
    signing = {
      signByDefault = true;
      key = "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBEuguFe5RLXSCgHUiwQ8WodII8gXcg0p1y19jcuY86pCFC8VuI1EJKFDhhEa8F79kLsgJK6VB29dsYVw1TKbVd8AAAAEc3NoOg== ben@nixos";
    };
    
    extraConfig = {
      color.ui = true;
      github.user = "benluelo";
			gpg.format = "ssh";
    };
  };
}
