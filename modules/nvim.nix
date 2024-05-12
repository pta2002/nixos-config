{ pkgs, inputs, ... }:
{
  programs.nixvim = {
    enable = true;
    plugins = {
      treesitter = {
        enable = true;
        nixGrammars = true;
        ensureInstalled = "all";
        moduleConfig.autotag = {
          enable = true;
          filetypes = [ "html" "xml" "astro" "javascriptreact" "typescriptreact" "svelte" "vue" ];
        };
        nixvimInjections = true;

        moduleConfig.highlight = {
          additional_vim_regex_highlighting = [ "org" ];
          enable = true;
          disable = [ "pug" ];
        };
      };

      comment.enable = true;

      lualine = {
        enable = true;
        theme = "kanagawa";
      };

      intellitab.enable = true;
      nix.enable = true;
      bufferline = {
        enable = true;
        diagnostics = "nvim_lsp";
        separatorStyle = "slant";
      };
      nvim-autopairs.enable = true;
      nvim-tree.enable = true;

      undotree.enable = true;
      surround.enable = true;

      lspkind = {
        enable = true;
        mode = "symbol_text";
        cmp.ellipsisChar = "…";
        cmp.menu = {
          buffer = "[Buffer]";
          nvim_lsp = "[LSP]";
          luasnip = "[LuaSnip]";
          nvim_lua = "[Lua]";
          latex_symbols = "[Latex]";
        };
        cmp.after = ''
          function(entry, vim_item, kind)
            local strings = vim.split(kind.kind, "%s", { trimempty = true })
            if #strings == 2 then
              kind.kind = " " .. strings[1] .. " "
              kind.menu = "   " .. strings[2]
            end

            return kind
          end
        '';
      };

      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          rust-analyzer.enable = true;
          rust-analyzer.installRustc = true;
          rust-analyzer.installCargo = true;
          clangd.enable = true;
          zls.enable = true;
          pyright.enable = true;
          gopls.enable = true;
          elixirls.enable = true;
          hls.enable = true;
          tsserver.enable = true;
          astro.enable = true;
          gleam.enable = true;
        };

        onAttach = /* lua */ ''
          vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
        '';
      };

      lsp-lines = {
        enable = false;
        currentLine = true;
      };

      lspsaga.enable = true;

      none-ls = {
        enable = true;
        sources.formatting.black.enable = true;
        # sources.formatting.beautysh.enable = true;
        # sources.diagnosticsFormat.shellcheck.enable = true;
        # sources.formatting.fourmolu.enable = true;
        sources.formatting.fnlfmt.enable = true;
      };

      trouble.enable = true;

      cmp_luasnip.enable = true;

      cmp = {
        enable = true;
        settings.sources = [{ name = "nvim_lsp"; }];
        # mappingPresets = [ "insert" ];
        # mapping = {
        #   "<CR>" = "cmp.mapping.confirm({ select = true })";
        # };
        settings.formatting.fields = [ "kind" "abbr" "menu" ];

        settings.window.completion = {
          winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None";
          colOffset = -4;
          sidePadding = 0;
          border = "single";
        };

        settings.window.documentation = {
          winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None";
          border = "single";
        };

        settings.snippet.expand = "luasnip";
      };

      zig.enable = true;

      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
      };

      conjure.enable = true;

      typst-vim.enable = true;

      # ts-autotag.enable = true;

      endwise.enable = true;

      nvim-colorizer.enable = true;

      toggleterm.enable = true;
      toggleterm.settings.open_mapping = "[[<c-t>]]";
    };

    colorschemes.kanagawa.enable = true;

    opts = {
      mouse = "a";
      shiftwidth = 2;
      tabstop = 2;
      smartindent = true;
      expandtab = true;
      number = true;
      relativenumber = false;
      wrap = true;
      linebreak = true;
      hlsearch = false;
      smartcase = true;
      ignorecase = true;

      undodir = "/home/pta2002/.cache/nvim/undodir";
      undofile = true;

      showmode = false;

      scrolloff = 4;
      clipboard = "unnamedplus";

      laststatus = 3;
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = [
      { key = "<leader>t"; action = "<CMD>NvimTreeToggle<CR>"; mode = "n"; }
      { key = "<leader>ft"; action = "<CMD>Telescope find_files<CR>"; mode = "n"; }
      { key = "<leader>fg"; action = "<CMD>Telescope grep_string<CR>"; mode = "n"; }
      { key = "<leader>ca"; action = "<CMD>Lspsaga code_action<CR>"; mode = "n"; }
      { key = "j"; action = "gj"; mode = "n"; }
      { key = "k"; action = "gk"; mode = "n"; }
      { key = "<C-S>"; action = "<C-O>:w<CR>"; mode = "i"; }
    ];

    extraConfigLua = ''
      require("scope").setup()
      require('git-conflict').setup()

      -- Make LSP shut up
      local notify = vim.notify
      vim.notify = function(msg, ...)
        if msg:match("warning: multiple different client offset_encodings") then
          return
        end

        notify(msg, ...)
      end
    '';

    extraPlugins = with pkgs.vimPlugins; [
      vim-sleuth
      luasnip
      (pkgs.vimUtils.buildVimPlugin {
        pname = "git-conflict.nvim";
        version = "master";
        src = pkgs.fetchFromGitHub {
          owner = "akinsho";
          repo = "git-conflict.nvim";
          rev = "3c89812a83ac749b8851a473863958325a1cd57c";
          hash = "sha256-yQvV8tDpjmMfmnWZrsXHgOEQsTFadHC46N6VdPXoX6o=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "glowbeam-nvim";
        version = "master";
        src = pkgs.fetchFromGitHub {
          owner = "cooperuser";
          repo = "glowbeam.nvim";
          rev = "12144d6062455425028390095d2932d566cbc851";
          hash = "sha256-EiwQYNLE2pRVifVkDw8WN7CkNcm5OOFu7jG3q7TlCyI=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "terminal-nvim";
        version = "764b7c137512bcfba2e45cf3e25c08a9f4d3b733";
        src = pkgs.fetchFromGitHub {
          owner = "rebelot";
          repo = "terminal.nvim";
          rev = version;
          sha256 = "1z8b16hp6gvy85wvrac5f7gsgl127src7z3s2zmkbrqksscxm0wf";
        };
      })
      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "janet-vim";
        version = "61eca1138bd149a86edbde39dc20a3130f0d9b39";
        src = pkgs.fetchFromGitHub {
          owner = "janet-lang";
          repo = "janet.vim";
          rev = version;
          sha256 = "1m9nyylwvb9ypgiqahjg6w6qzl8536p2s5vciais1slpjhrx9iqg";
        };

        buildInputs = with pkgs; [ janet ];
      })
      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "nvim-parinfer";
        version = "c0d95d9f4c5f921872ba11790b76efbb02cc8af5";
        src = pkgs.fetchFromGitHub {
          owner = "gpanders";
          repo = "nvim-parinfer";
          rev = version;
          sha256 = "0sk6nwppvxznr6lc5zh8rj8pgqa2qi18d0d4r97ap00d59krb6f4";
        };
      })
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
        pname = "scope-nvim";
        version = "2db6d31de8e3a98d2b41c0f0d1f5dc299ee76875";
        src = pkgs.fetchFromGitHub {
          owner = "tiagovla";
          repo = "scope.nvim";
          rev = version;
          sha256 = "10l7avsjcgzh0s29az4zzskqcp9jw5xpvdiih02rf7c1j85zxm85";
        };
      })
      vim-terraform
      gleam-vim
    ];

    extraPackages = [ pkgs.xclip pkgs.glslls ];

    highlight = {
      PmenuSel = { bg = "#504945"; fg = "NONE"; };
      Pmenu = { fg = "#ebdbb2"; bg = "#282828"; };

      CmpItemAbbrDeprecated = { fg = "#d79921"; bg = "NONE"; strikethrough = true; };
      CmpItemAbbrMatch = { fg = "#83a598"; bg = "NONE"; bold = true; };
      CmpItemAbbrMatchFuzzy = { fg = "#83a598"; bg = "NONE"; bold = true; };
      CmpItemMenu = { fg = "#b16286"; bg = "NONE"; italic = true; };

      CmpItemKindField = { fg = "#fbf1c7"; bg = "#fb4934"; };
      CmpItemKindProperty = { fg = "#fbf1c7"; bg = "#fb4934"; };
      CmpItemKindEvent = { fg = "#fbf1c7"; bg = "#fb4934"; };

      CmpItemKindText = { fg = "#fbf1c7"; bg = "#b8bb26"; };
      CmpItemKindEnum = { fg = "#fbf1c7"; bg = "#b8bb26"; };
      CmpItemKindKeyword = { fg = "#fbf1c7"; bg = "#b8bb26"; };

      CmpItemKindConstant = { fg = "#fbf1c7"; bg = "#fe8019"; };
      CmpItemKindConstructor = { fg = "#fbf1c7"; bg = "#fe8019"; };
      CmpItemKindReference = { fg = "#fbf1c7"; bg = "#fe8019"; };

      CmpItemKindFunction = { fg = "#fbf1c7"; bg = "#b16286"; };
      CmpItemKindStruct = { fg = "#fbf1c7"; bg = "#b16286"; };
      CmpItemKindClass = { fg = "#fbf1c7"; bg = "#b16286"; };
      CmpItemKindModule = { fg = "#fbf1c7"; bg = "#b16286"; };
      CmpItemKindOperator = { fg = "#fbf1c7"; bg = "#b16286"; };

      CmpItemKindVariable = { fg = "#fbf1c7"; bg = "#458588"; };
      CmpItemKindFile = { fg = "#fbf1c7"; bg = "#458588"; };

      CmpItemKindUnit = { fg = "#fbf1c7"; bg = "#d79921"; };
      CmpItemKindSnippet = { fg = "#fbf1c7"; bg = "#d79921"; };
      CmpItemKindFolder = { fg = "#fbf1c7"; bg = "#d79921"; };

      CmpItemKindMethod = { fg = "#fbf1c7"; bg = "#8ec07c"; };
      CmpItemKindValue = { fg = "#fbf1c7"; bg = "#8ec07c"; };
      CmpItemKindEnumMember = { fg = "#fbf1c7"; bg = "#8ec07c"; };

      CmpItemKindInterface = { fg = "#fbf1c7"; bg = "#83a598"; };
      CmpItemKindColor = { fg = "#fbf1c7"; bg = "#83a598"; };
      CmpItemKindTypeParameter = { fg = "#fbf1c7"; bg = "#83a598"; };

      FloatBorder = { fg = "#a89984"; };
    };
  };
}
