{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  luaCheck,
  inputs',
}:
with sources;
{
  doc = ''
    # nvim-cmp

    ## 概要
    外部ソースの候補をまとめる Lua 製の補完エンジン。

    ## 主な機能
    - LSP 補完機能と複数の補完ソースを扱う。
    - 補完キーや候補の表示、コマンドライン補完を Lua で設定できる。

    ## 使い方
    `cmp.setup()` で `sources`、`mapping`、`snippet.expand` を設定する。`cmp.setup.cmdline()` で検索・コマンド補完を設定する。この定義は LuaSnip でスニペットを展開する。

    ## 要件
    補完ソースは別リポジトリーから導入する。README の設定例はスニペットエンジン指定を必須としている。最低 Neovim バージョンは README に未記載。

    ## 出典
    [固定バージョンの README](https://github.com/hrsh7th/nvim-cmp/blob/fe29aba4117227a6df637bc41e4b4fb4e98864a0/README.md)
  '';

  plugin = sources.nvim-cmp;
  dependPlugins = [
    definitions.LuaSnip
    definitions.lspkind-nvim
  ];
  config = luaConfig (
    # lua
    ''
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      lspkind.setup({
        symbol_map = {
          Text = "󰉿",
          Method = "󰊕",
          Function = "󰊕",
          Constructor = "󰒓",
          Field = "󰜢",
          Variable = "󰀫",
          Class = "󰠱",
          Interface = "",
          Module = "",
          Property = "󰜢",
          Unit = "",
          Value = "󰎠",
          Enum = "",
          Keyword = "󰌋",
          Snippet = "",
          Color = "󰏘",
          File = "󰈔",
          Reference = "󰈇",
          Folder = "󰉋",
          EnumMember = "",
          Constant = "󰏿",
          Struct = "󰙅",
          Event = "",
          Operator = "󰆕",
          TypeParameter = "󰗴",
        },
      })

      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              if luasnip.expandable() then
                luasnip.expand()
              else
                cmp.confirm({
                  select = false,
                })
              end
            else
              fallback()
            end
          end),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-x>f"] = function()
            cmp.complete({
              config = {
                sources = {
                  { name = "path" },
                },
              },
            })
          end,
          ["<C-x>l"] = function()
            cmp.complete({
              config = {
                sources = {
                  { name = "nvim_lsp" },
                },
              },
            })
          end,
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol",
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
      })

      -- Cycle through candidates while applying each one. The first <Tab> opens the
      -- menu and immediately selects/inserts the first candidate (cmdline sources are
      -- synchronous, so entries are available right after cmp.complete()).
      local function cmdline_select(select_item)
        return {
          c = function()
            if not cmp.visible() then
              cmp.complete()
            end
            if cmp.visible() then
              select_item({ behavior = cmp.SelectBehavior.Insert })
            end
          end,
        }
      end

      local cmdline_mapping = cmp.mapping.preset.cmdline({
        ["<Tab>"] = cmdline_select(cmp.select_next_item),
        ["<S-Tab>"] = cmdline_select(cmp.select_prev_item),
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmdline_mapping,
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmdline_mapping,
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })

      vim.cmd([[
      cnoremap <expr> <C-a> '<Home>'
      cnoremap <expr> <C-e> '<End>'
      cnoremap <expr> <C-b> '<Left>'
      cnoremap <expr> <C-f> '<Right>'
      ]])
    ''
  );
  tests.cmp-luasnip-expansion = luaCheck {
    name = "cmp-luasnip-expansion";
    script = ''
      vim.cmd.enew()
      local cmp = require("cmp")
      local config = cmp.get_config()
      local names = vim.tbl_map(function(source) return source.name end, config.sources)
      assert(vim.deep_equal(names, { "nvim_lsp", "luasnip", "buffer" }), vim.inspect(names))
      config.snippet.expand({ body = 'say("''${1:hello}", ''${2:42})$0' })
      assert(vim.api.nvim_get_current_line() == 'say("hello", 42)', "configured cmp expansion did not expand LuaSnip placeholders")
      local luasnip = require("luasnip")
      assert(luasnip.locally_jumpable(1), "expanded snippet has no forward placeholder jump")
      luasnip.jump(1)
      assert(luasnip.session.current_nodes[vim.api.nvim_get_current_buf()].pos == 2,
        "LuaSnip did not jump to the second placeholder")
      luasnip.jump(-1)
      assert(luasnip.session.current_nodes[vim.api.nvim_get_current_buf()].pos == 1,
        "LuaSnip did not jump back to the first placeholder")
    '';
  };
}
