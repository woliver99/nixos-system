# Common files for my nixvim config

# sudo nix-channel --add https://github.com/nix-community/nixvim/archive/refs/heads/nixos-25.11.tar.gz nixvim && sudo nix-channel --update nixvim

{ pkgs, ... }:

let
  nixvim = import <nixvim>;
in
{
  imports = [ nixvim.nixosModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    globals.mapleader = " ";

    opts = {
      number = true;
      shiftwidth = 2;
      expandtab = true;
      smartindent = false;
    };

    extraPackages = with pkgs; [
      tree-sitter
      nodejs

      nixfmt-rfc-style
    ];

    keymaps = [
      {
        mode = "n";
        key = "=";
        action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true })<CR>";
        options.desc = "Format the whole file";
      }
      {
        mode = "v";
        key = "c";
        action = "\"+y"; # Note the \" escaping the quote
        options.desc = "Copy to system clipboard";
      }
      {
        mode = "v";
        key = "x";
        action = "\"+x";
        options.desc = "Cut to system clipboard";
      }
      {
        mode = "v";
        key = "d";
        action = "\"_d";
        options.desc = "Delete without copying";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>NvimTreeToggle<CR>";
        options.desc = "Toggle Explorer";
      }
    ];

    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "macchiato";
    };

    plugins = {
      # File Explorer
      nvim-tree = {
        enable = true;
        settings = {
          filters.dotfiles = false;
          disable_netrw = true;
          hijack_cursor = true;
          sync_root_with_cwd = true;
          update_focused_file = {
            enable = true;
            update_root = false;
          };
          view = {
            side = "right";
            width = 30;
            preserve_window_proportions = true;
          };
          renderer = {
            root_folder_label = false;
            highlight_git = true;
            indent_markers.enable = true;
            icons.glyphs.git = {
              unstaged = "";
              #untracked = "";
            };
          };
        };
      };

      # Tab Bar
      bufferline.enable = true;

      # Status Bar
      lualine.enable = true;

      # Nerdfont Icons Support
      web-devicons.enable = true;

      # Automatically detects tabstop/shiftwidth per file
      sleuth.enable = true;

      # Surround visual selections easily (TODO)
      # nvim-surround.enable = true;

      # Show git changes
      gitsigns.enable = true;

      # Ask for sudo password when needed
      vim-suda.enable = true;

      # Syntax Highlighting
      treesitter = {
        enable = true;
        nixGrammars = true;
        grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;

        settings = {
          highlight = {
            enable = true;
            disable = [ "gitcommit" ];
          };
          indent.enable = true;
          folding.enable = true;
        };
      };

      # Completion
      cmp = {
        enable = true;
        autoEnableSources = true;

        settings = {
          mapping = {
            # (Tab) to confirm the selection
            "<Tab>" = "cmp.mapping.confirm({ select = true })";

            # (Shift-Tab) to close the completion menu
            "<S-Tab>" = "cmp.mapping.close()";

            # (Up and Down arrows) to cycle through tablist
            "<Up>" = "cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' })";
            "<Down>" = "cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' })";

            # (Ctrl-Space) Open tab menu
            "<C-Space>" = "cmp.mapping.complete()";
          };

          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
        };
      };

      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          rust_analyzer = {
            enable = true;
            package = null;
            installCargo = false;
            installRustc = false;
          };
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            nix = [ "nixfmt" ];
            #rust = [ "rustfmt" ];
          };
        };

      };
    };
  };

  environment.systemPackages = with pkgs; [
    gcc
    ripgrep

    # Language Servers
    lua-language-server
    nixd

    # Formatters
    nixfmt-rfc-style

    # vi and vim alias
    (pkgs.writeShellScriptBin "vi" "exec nvim \"$@\"")
    (pkgs.writeShellScriptBin "vim" "exec nvim \"$@\"")
  ];
}
