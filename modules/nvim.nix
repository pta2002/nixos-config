inputs: { pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    plugins = {
      treesitter.enable = true;
      treesitter.nixGrammars = true;
      treesitter.ensureInstalled = "all";
      comment-nvim.enable = true;

      lualine = {
        enable = true;
        theme = "gruvbox-material";
      };

      intellitab.enable = true;
      nix.enable = true;
      bufferline.enable = true;
      nvim-autopairs.enable = true;
      nvim-tree.enable = true;

      undotree.enable = true;
      surround.enable = true;

      lsp = {
        enable = true;
        servers = {
          rnix-lsp.enable = true;
          rust-analyzer.enable = true;
          clangd.enable = true;
          zls.enable = true;
          pyright.enable = true;
          gopls.enable = true;
          elixirls.enable = true;
        };

        onAttach = ''
          vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
        '';
      };

      lsp-lines.enable = true;

      nvim-cmp = {
        enable = true;
        sources = [{ name = "nvim_lsp"; }];
        mappingPresets = [ "insert" ];
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
        };
      };

      zig.enable = true;

      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
      };
    };

    # colorscheme = "kanagawa";
    colorschemes.gruvbox = {
      enable = true;
      contrastDark = "hard";
    };

    options = {
      mouse = "a";
      shiftwidth = 2;
      tabstop = 2;
      smartindent = true;
      expandtab = true;
      number = true;
      wrap = true;
      linebreak = true;
      hlsearch = false;
      relativenumber = true;
      smartcase = true;
      ignorecase = true;

      undodir = "/home/pta2002/.cache/nvim/undodir";
      undofile = true;

      showmode = false;

      scrolloff = 4;
      clipboard = "unnamedplus";
    };

    globals.mapleader = " ";

    maps.normal = {
      "<leader>t" = "<CMD>NvimTreeToggle<CR>";
      "<leader>ft" = "<CMD>Telescope find_files<CR>";
      "<leader>fg" = "<CMD>Telescope grep_string<CR>";
      "j" = "gj";
      "k" = "gk";
    };

    extraPlugins = with pkgs.vimPlugins; [
      vim-sleuth
      kanagawa-nvim
      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "vim-sxhkdrc";
        version = "7b8abc305ba346c3af7d57da0ebec2b2f2d3f5b0";
        src = pkgs.fetchFromGitHub {
          owner = "baskerville";
          repo = "vim-sxhkdrc";
          rev = version;
          sha256 = "0x82zpm9zwhaadwp5rp8gsw4ldc0arvra0pdmkjb327qvpd0ns6j";
        };
      })
      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "yuck-vim";
        version = "6dc3da77c53820c32648cf67cbdbdfb6994f4e08";
        src = pkgs.fetchFromGitHub {
          owner = "elkowar";
          repo = "yuck.vim";
          rev = version;
          sha256 = "0890cyxnnvbbhv1irm0nxl5x7a49h1327cmhl1gmayigd4jym7ln";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "vim-tup";
        version = "eede19c";
        src = inputs.vim-tup;
      })
      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "vim-alloy";
        version = "961d9608bdcfd34d6a01cecbb49c6ddf6382fb82";
        src = pkgs.fetchFromGitHub {
          owner = "runoshun";
          repo = "vim-alloy";
          rev = version;
          sha256 = "1cdmbk3kwkwvkl5jqg7g6fcg00ca6svwl8hkdr4hiz4qf04qx77y";
        };
      })
      vim-endwise
      vim-terraform
    ];

    extraPackages = [ pkgs.xclip ];
  };
}
