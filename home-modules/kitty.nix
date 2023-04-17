{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    
    settings = {
			cursor_blink_interval = 0;
      allow_remote_control = "yes";
		};
    
    font = {
      name = "JetBrains Mono";
      size = 12;
    };
    
    # keybindings = {};

    theme = "One Dark";
  };
}
