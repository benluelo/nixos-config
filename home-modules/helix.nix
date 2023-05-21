{ inputs, pkgs, theme, ... }:
{
  programs.helix = {
    enable = true;
    package = inputs.helix.packages.${pkgs.system}.default;

    settings = {
      theme = "onedark";
      editor = {
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        auto-format = true;
        # completion-trigger-len = 0;
        # scroll-lines = 1;
        # scrolloff = 5;
        # cursorline = true;
        # color-modes = true;
        # indent-guides.render = true;
        file-picker.hidden = false;
        auto-pairs = false;
        lsp.display-messages = true;
        # bufferline = "always";
        # statusline = {
        #   left = [ "mode" "spinner" "file-name" ];
        #   right = [ "diagnostics" "position" "total-line-numbers" "file-encoding" ];
        # };
        soft-wrap = {
          enable = true;
        };
      };
    };

    languages = [
      {
        name = "rust";
        config = {
          checkOnSave.command = "clippy";
          # Careful! If you enable this, then a lot of errors
          # will no longer show up in Helix. Do not enable it.
          # cargo.allFeatures = true; <- do NOT enable me
        };
      }
      {
        name = "nix";
        config = {
          auto-format = true;
        };
      }
    ];
  };
}
