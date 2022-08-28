{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    plugins = {
      treesitter.enable = true;
      treesitter.nixGrammars = false;
      treesitter.ensureInstalled = "all";
      comment-nvim.enable = true;

      lualine = {
        enable = true;
        theme = "kanagawa";
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

    colorscheme = "kanagawa";

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
    ];

    extraPackages = [ pkgs.xclip ];
  };
}
