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
    nvim-cmp 本体と 5 つの補完ソースをまとめ、共通の補完設定を一度適用するグループ。

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

    # cmp-buffer

    ## 概要
    バッファ内の単語を nvim-cmp の補完候補として提供する。

    ## 主な機能
    - 単語抽出パターンと補完開始文字数の設定。
    - 候補を収集するバッファの選択。

    ## 使い方
    nvim-cmp の `sources` に `{ name = "buffer" }` を追加する。`option.keyword_length`・`option.keyword_pattern` などで候補を調整する。

    ## 要件
    nvim-cmp 用の補完ソース。最低バージョンは README に未記載。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/hrsh7th/cmp-buffer/blob/b74fab3656eea9de20a9b8116afa3cfc4ec09657/README.md)

    # cmp-cmdline

    ## 概要
    nvim-cmp に Vim コマンドラインの補完候補を提供する。

    ## 主な機能
    - コマンドモードで補完する。
    - `ignore_cmds` で候補取得を除外するコマンドを指定する。

    ## 使い方
    `cmp.setup.cmdline(":", ...)` の `sources` に `{ name = "cmdline" }` を登録する。README の検索補完例で使う `buffer` は別の補完ソース。

    ## 要件
    nvim-cmp が必要。README の `/` 検索補完例には別途 cmp-buffer が必要。

    ## 出典
    [固定バージョンの README](https://github.com/hrsh7th/cmp-cmdline/blob/d126061b624e0af6c3a556428712dd4d4194ec6d/README.md)

    # cmp-nvim-lsp

    ## 概要
    Neovim 内蔵 LSP クライアントの補完候補を nvim-cmp に提供するソース。

    ## 主な機能
    - LSP 補完向けのクライアント capabilities を生成。
    - 言語サーバーごとの keyword_pattern を設定可能。

    ## 使い方
    nvim-cmp のソースに `nvim_lsp` を追加し、`require("cmp_nvim_lsp").default_capabilities()` の結果を LSP 設定に渡す。README は、この capabilities を使うと内蔵 omnifunc に互換性がなくなると注意している。

    ## 要件
    nvim-cmp と Neovim 内蔵 LSP クライアントを使用する。最低バージョンは README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/hrsh7th/cmp-nvim-lsp/blob/cd4ee08a988deb47ac3726f418fb27fe1a95729d/README.md)

    # cmp-path

    ## 概要
    ファイルシステムのパスを nvim-cmp で補完する。

    ## 主な機能
    - 相対パスの基準ディレクトリとパス別名の設定。
    - ディレクトリ末尾のスラッシュ表示・挿入の調整。

    ## 使い方
    nvim-cmp の `sources` に `{ name = "path" }` を追加する。`option.pathMappings` や `option.get_cwd` でパス解決を調整する。

    ## 要件
    nvim-cmp 用の補完ソース。最低バージョンは README に未記載。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/hrsh7th/cmp-path/blob/c642487086dbd9a93160e1679a1327be111cbc25/README.md)

    # cmp_luasnip

    ## 概要
    LuaSnip のスニペットを nvim-cmp の補完候補として提供する。

    ## 主な機能
    - スニペットの `show_condition` による候補の絞り込みに対応する。
    - 自動展開スニペットを候補へ含めるかを設定できる。

    ## 使い方
    nvim-cmp の `sources` に `{ name = "luasnip" }` を登録し、`snippet.expand` で `require("luasnip").lsp_expand(args.body)` を呼ぶ。

    ## 要件
    LuaSnip と nvim-cmp が必要。

    ## 出典
    [固定バージョンの README](https://github.com/saadparwaiz1/cmp_luasnip/blob/98d9cb5c2c38532bd9bdb481067b20fea8f32e90/README.md)
  '';

  packages = [
    sources.nvim-cmp
    sources.cmp-buffer
    sources.cmp-cmdline
    sources.cmp-nvim-lsp
    sources.cmp-path
    sources.cmp_luasnip
  ];
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
    preInit = ''
      -- Observe the real setup call before the full profile initializes.
      _G.cmp_group_setup_calls = 0
      local original_require = require
      local wrapped = false
      _G.require = function(name)
        local module = original_require(name)
        if name == "cmp" and not wrapped then
          wrapped = true
          local mt = getmetatable(module.setup)
          local original_call = mt.__call
          mt.__call = function(...)
            _G.cmp_group_setup_calls = _G.cmp_group_setup_calls + 1
            return original_call(...)
          end
          _G.require = original_require
        end
        return module
      end
    '';
    script = ''
      assert(_G.cmp_group_setup_calls == 1,
        "shared cmp setup must run once, got " .. tostring(_G.cmp_group_setup_calls))
      vim.cmd.enew()
      local cmp = require("cmp")
      -- cmp-nvim-lsp registers only after a completion-capable client attaches.
      -- Use Neovim's real client lifecycle with a minimal in-process RPC server.
      local client_id = assert(vim.lsp.start({
        name = "cmp-group-check",
        cmd = function(dispatchers)
          local closing = false
          local request_id = 0
          return {
            request = function(method, _, callback)
              request_id = request_id + 1
              local result = method == "initialize"
                and { capabilities = { completionProvider = {} } } or nil
              vim.schedule(function() callback(nil, result) end)
              return true, request_id
            end,
            notify = function() return true end,
            is_closing = function() return closing end,
            terminate = function()
              closing = true
              vim.schedule(function() dispatchers.on_exit(0, 0) end)
            end,
          }
        end,
      }), "could not start completion test client")
      assert(vim.wait(5000, function()
        local client = vim.lsp.get_client_by_id(client_id)
        return client and client.initialized and vim.lsp.buf_is_attached(0, client_id)
      end), "completion test client did not initialize and attach")
      vim.api.nvim_exec_autocmds("InsertEnter", { buffer = 0 })
      local registered = {}
      for _, source in pairs(cmp.get_registered_sources()) do
        registered[source.name] = (registered[source.name] or 0) + 1
      end
      for _, name in ipairs({ "buffer", "cmdline", "nvim_lsp", "path", "luasnip" }) do
        assert(registered[name] == 1,
          "expected one registered " .. name .. " source, got " .. tostring(registered[name]))
      end
      vim.lsp.get_client_by_id(client_id):stop(true)
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
