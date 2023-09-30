{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;

    settings = {
      scrollback_lines = 100000000;
      cursor_blink_interval = 0;
      allow_remote_control = true;
    };

    font = {
      name = "JetBrains Mono Nerd Font";
      size = 10;
    };

    # keybindings = {};

    theme = "One Dark";

    extraConfig = ''
      symbol_map U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,U+E0B0-U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6AA,U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F32F,U+F400-U+F4A9,U+F500-U+F8FF,U+F0001-U+F1AF0 JetBrainsMono Nerd Font
    '';
  };
}
