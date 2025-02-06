{ pkgs, inputs, ... }:
{
  programs.nixvim = {
    enable = true;
    plugins = {
      treesitter = {
        enable = true;
        nixGrammars = true;
        nixvimInjections = true;

        settings = {
          autotag = {
            enable = true;
            filetypes = [ "html" "xml" "astro" "javascriptreact" "typescriptreact" "svelte" "vue" ];
          };

          highlight = {
            additional_vim_regex_highlighting = [ "org" ];
            enable = true;
            disable = [ "pug" ];
          };

          folding = true;
        };
      };

      comment.enable = true;

      lualine = {
        enable = true;
        settings.options.theme = "kanagawa";
      };

      intellitab.enable = true;
      nix.enable = true;
      bufferline = {
        enable = true;
        settings.options.diagnostics = "nvim_lsp";
        settings.options.separator_style = "slant";
      };
      nvim-autopairs.enable = true;
      nvim-tree.enable = true;

      undotree.enable = true;
      vim-surround.enable = true;

      # Enabled because of telescope, lspsaga, nvim-tree, trouble and bufferline. Can be replaced by mini.
      web-devicons.enable = true;

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
        cmp.after = /* lua */ ''
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
          nixd = {
            enable = true;
            settings.formatting.command = [ "nixpkgs-fmt" ];
          };
          # TODO: https://github.com/nix-community/nixvim/issues/1702
          # rust-analyzer.enable = true;
          # rust-analyzer.installRustc = true;
          # rust-analyzer.installCargo = true;
          clangd.enable = true;
          zls.enable = true;
          pyright.enable = true;
          gopls.enable = true;
          elixirls.enable = true;
          ts_ls.enable = true;
          astro.enable = true;
          gleam.enable = true;
        };
      };

      lsp-format = {
        enable = true;
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

      cmp-nvim-lsp.enable = true;
      cmp_luasnip.enable = true;
      cmp = {
        autoEnableSources = true;
        enable = true;
        settings = {
          sources = [{ name = "nvim_lsp"; } { name = "luasnip"; }];
          formatting.fields = [ "kind" "abbr" "menu" ];

          snippet.expand = /* lua */ ''function(args)
            require('luasnip').lsp_expand(args.body)
          end'';

          window.completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None";
            colOffset = -4;
            sidePadding = 0;
            border = "single";
          };

          mapping = {
            "<CR>" = /* lua */ ''
              cmp.mapping.confirm({
                i = function(fallback)
                  if cmp.visible() and cmp.get_active_entry() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                  else
                    fallback()
                  end
                end,
                s = cmp.mapping.confirm({ select = true }),
                c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
              })
            '';
            "<C-Space>" = "cmp.mapping.complete()";
            "<Down>" = /* lua */ ''cmp.mapping(cmp.mapping.select_next_item({
              beahavior = cmp.SelectBehavior.Select
            }), {'i', 'c'})'';
            "<Up>" = /* lua */ ''cmp.mapping(cmp.mapping.select_prev_item({
              beahavior = cmp.SelectBehavior.Select
            }), {'i', 'c'})'';

            "<Tab>" = /* lua */ ''cmp.mapping(function(fallback)
              local luasnip = require("luasnip")
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.locally_jumpable(1) then
                luasnip.jump(1)
              else
                fallback()
              end
            end, { 'i', 's' })'';

            "<S-Tab>" = /* lua */ ''cmp.mapping(function(fallback)
              local luasnip = require("luasnip")
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { 'i', 's' })'';
          };

          window.documentation = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None";
            border = "single";
          };
        };
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

      colorizer.enable = true;

      toggleterm.enable = true;
      toggleterm.settings.open_mapping = "[[<c-t>]]";

      luasnip.enable = true;
      sleuth.enable = true;

      git-conflict.enable = true;
      neogit = {
        enable = true;
      };

      parinfer-rust.enable = true;
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
      # Don't want folding at startup
      foldenable = false;
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
      { key = "<leader>g"; action = "<CMD>Neogit cwd=%:p:h<CR> kind=auto"; mode = "n"; }
    ];

    autoCmd = [
      {
        event = "User";
        pattern = "UnceptionEditRequestReceived";
        command = "ToggleTerm";
      }
    ];

    extraConfigLua = ''
      require("scope").setup()

      -- Make LSP shut up
      local notify = vim.notify
      vim.notify = function(msg, ...)
        if msg:match("warning: multiple different client offset_encodings") then
          return
        end

        notify(msg, ...)
      end
    '';


    extraPlugins = [
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
      pkgs.vimPlugins.terminal-nvim
      pkgs.vimPlugins.scope-nvim
      pkgs.vimPlugins.vim-terraform
      pkgs.vimPlugins.gleam-vim
      pkgs.vimPlugins.nvim-unception
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
