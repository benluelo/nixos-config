{ inputs, pkgs, theme, ... }:
{
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    ibm-plex
    fira-code
    fira-code-symbols
    jetbrains-mono
    (pkgs.nerdfonts.override {
      fonts = [ "JetBrainsMono" ];
    })
  ];
}
