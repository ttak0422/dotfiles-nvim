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
    Telescope 本体と 5 つの拡張をまとめ、picker と選択 UI の設定を共有する。

    # telescope.nvim

    ## 概要
    一覧を検索・選択・プレビューする拡張可能なファジーファインダー。

    ## 主な機能
    - ファイル、バッファ、ヘルプなどの組み込み picker を提供する。
    - picker、ソーター、プレビュー、レイアウトを個別に拡張できる。

    ## 使い方
    `:Telescope find_files`、`:Telescope buffers`、`:Telescope help_tags` を使う。全文検索には `require("telescope.builtin").live_grep()`、導入確認には `:checkhealth telescope` を使う。

    ## 要件
    LuaJIT 付き Neovim 0.11.7 以上と plenary.nvim。live_grep / grep_string には ripgrep が必要。fd、アイコン、ネイティブソーターは推奨の追加機能。

    ## 出典
    [固定バージョンの README](https://github.com/nvim-telescope/telescope.nvim/blob/40aedd8a68c78a656a10a8d62d80c54af59420fb/README.md)

    # telescope-fzf-native.nvim

    ## 概要
    fzf の照合アルゴリズムを C で実装した Telescope 用ソーター。

    ## 主な機能
    - あいまい一致、完全一致、前方・後方一致、否定、OR に対応する。
    - 一致スコアと位置を計算し、Telescope のソートを置き換える。

    ## 使い方
    Telescope の設定後に `require("telescope").load_extension("fzf")` を呼ぶ。`extensions.fzf` で `fuzzy`、`case_mode`、既存ソーターの置換を設定する。

    ## 要件
    Telescope との連携を前提とする。ネイティブ部分のビルドには make と GCC / Clang、または CMake を使用する。Windows の CMake 構成には Microsoft C++ Build Tools が必要。

    ## 出典
    [固定バージョンの README](https://github.com/nvim-telescope/telescope-fzf-native.nvim/blob/b25b749b9db64d375d782094e2b9dce53ad53a40/README.md)

    # telescope-ghq.nvim

    ## 概要
    ghq 管理下のリポジトリを選ぶ Telescope extension。

    ## 主な機能
    - `ghq list` の結果を picker に表示。
    - 選択先で Git ファイル検索やディレクトリ変更。

    ## 使い方
    ghq extension を読み込んだ後、`:Telescope ghq` を実行する。Enter で `git_files`、`<C-x>` / `<C-v>` / `<C-t>` で全体・ウィンドウ・タブのディレクトリを変更する。

    ## 要件
    telescope.nvim と ghq を使用する。README は `ghq list` のみ対応と記載。最低バージョンは未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/nvim-telescope/telescope-ghq.nvim/blob/2bd2e2d10f1a06fce9cce1e33ffe464c84ceb63b/README.md)

    # Telescope live grep args

    ## 概要
    Telescope の live grep に検索コマンドの引数を入力できる拡張。

    ## 主な機能
    - 検索語とディレクトリ・glob・型指定などの同時入力。
    - クォート補助や自動クォートの調整。

    ## 使い方
    `require("telescope").load_extension("live_grep_args")` 後、`require("telescope").extensions.live_grep_args.live_grep_args()` を呼ぶ。入力例は `"foo" --iglob **/test/**`。

    ## 要件
    telescope.nvim と使用する grep コマンド。README の検索例は ripgrep を使用し、最低バージョンは未記載。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/nvim-telescope/telescope-live-grep-args.nvim/blob/53e9df55b3651dd7cf77e172f1e8c9a17407acca/README.md)

    # telescope-sonictemplate.nvim

    ## 概要
    vim-sonictemplate のテンプレートを Telescope から選ぶための統合。

    ## 主な機能
    - Telescope picker でテンプレートを選択。

    ## 使い方
    extension の読込後、`:Telescope sonictemplate templates` または `require("telescope").extensions.sonictemplate.templates{}` を実行する。

    ## 要件
    telescope.nvim、vim-sonictemplate。最低バージョンは README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/tamago324/telescope-sonictemplate.nvim/blob/9edeeea022d9e35287fa80a91ed5bffb950cc096/README.md)

    # telescope-ui-select.nvim

    ## 概要
    Neovim の `vim.ui.select` を Telescope の picker で表示する。

    ## 主な機能
    - LSP コードアクションなどの選択 UI を統一。
    - dropdown テーマや項目種別ごとの表示調整。

    ## 使い方
    Telescope の `extensions["ui-select"]` を設定し、setup 後に `require("telescope").load_extension("ui-select")` を呼ぶ。以後 `vim.ui.select` を使う機能に適用される。

    ## 要件
    telescope.nvim。README は Neovim 0.7 またはそれ以降の nightly を要求する。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/nvim-telescope/telescope-ui-select.nvim/blob/6e51d7da30bd139a6950adf2a47fda6df9fa06d2/README.md)
  '';

  lazy = true;
  onCommands = [
    "Telescope"
    "TelescopeBuffer"
    "TelescopeBufferName"
  ];
  onModules = [ "telescope" ];
  packages = with sources; [
    telescope-nvim
    telescope-fzf-native-nvim
    telescope-ghq-nvim
    telescope-live-grep-args-nvim
    telescope-sonictemplate-nvim
    telescope-ui-select-nvim
  ];
  dependPlugins = [
    definitions.plenary-nvim
    definitions.project-nvim
    definitions.vim-sonictemplate
    definitions.worktab-nvim
    definitions.pterm
    definitions.track
  ];
  extraPackages = with pkgs; [
    ripgrep
    ghq
  ];
  config = luaConfig (
    # lua
    ''
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")
      local actions = require("telescope.actions")
      local lga_actions = require("telescope-live-grep-args.actions")
      telescope.setup({
        defaults = {
          path_display = { "truncate" },
          prompt_prefix = " ",
          selection_caret = " ",
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            width = 0.87,
            height = 0.8,
          },
          mappings = {
            i = {
              ["<C-j>"] = { "<Plug>(goda-skk-enable)", type = "command" },
              ["<Down>"] = actions.cycle_history_next,
              ["<Up>"] = actions.cycle_history_prev,
            },
            n = {
              ["<Down>"] = actions.cycle_history_next,
              ["<Up>"] = actions.cycle_history_prev,
            },
          },
        },
        extensions = {
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ["<C-t>"] = lga_actions.quote_prompt({ postfix = " -t " }),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
              },
            },
            additional_args = function()
              return { "--hidden", "--glob", "!.git/**" }
            end,
          },
        },
      })
      for _, extension in ipairs({ "ui-select", "live_grep_args", "sonictemplate", "projects", "ghq", "worktab", "track" }) do
        telescope.load_extension(extension)
      end
      -- Telescope owns its pterm picker integration; standalone Pterm needs no picker.
      local pterm = require("pterm")
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local parser = require("telescope-live-grep-args.prompt_parser")

      telescope.load_extension("pterm")

      local function create_session(prompt_bufnr)
        local prompt = vim.trim(action_state.get_current_line())
        local names = pterm.list()
        -- Preserve existing names containing spaces instead of parsing them as commands.
        local argv = vim.tbl_contains(names, prompt) and { prompt } or parser.parse(prompt, false)
        local name, command = argv[1], argv[2]
        if not name or name == "" then
          actions.close(prompt_bufnr)
          return
        end
        if command and vim.tbl_contains(names, name) then
          vim.notify("Session '" .. name .. "' already exists; select it without a command", vim.log.levels.ERROR)
          return
        end
        if command and vim.fn.executable(command) == 0 then
          vim.notify("Executable not found: " .. command, vim.log.levels.ERROR)
          return
        end
        actions.close(prompt_bufnr)
        local ok, err = pcall(pterm.open, name, argv)
        if not ok then
          vim.notify("Failed to open session '" .. name .. "': " .. tostring(err), vim.log.levels.ERROR)
        end
      end

      local extension = telescope.extensions.pterm
      local sessions = extension.sessions
      local function configured_sessions(opts)
        opts = vim.tbl_extend("force", {}, opts or {})
        local attach = opts.attach_mappings
        opts.prompt_title = opts.prompt_title or "pterm sessions | new: name [command args...]"
        opts.attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace_if(function()
            return action_state.get_selected_entry() == nil
          end, function()
            create_session(prompt_bufnr)
          end)
          if attach then
            return attach(prompt_bufnr, map)
          end
          return true
        end
        return sessions(opts)
      end
      extension.sessions = configured_sessions
      extension.pterm = configured_sessions

      vim.api.nvim_create_user_command("TelescopeBuffer", function()
        builtin.live_grep({ grep_open_files = true })
      end, {})
      vim.api.nvim_create_user_command("TelescopeBufferName", function()
        builtin.buffers({ sort_mru = true, ignore_current_buffer = false })
      end, {})
    ''
  );
  tests.telescope-extensions-and-ui-select = luaCheck {
    name = "telescope-extensions-and-ui-select";
    preInit = ''
      local original_require = require
      local wrapped = false
      _G.telescope_test_setup_calls = 0
      _G.require = function(name)
        local module = original_require(name)
        if name == "telescope" and not wrapped then
          wrapped = true
          local setup = module.setup
          module.setup = function(...)
            _G.telescope_test_setup_calls = _G.telescope_test_setup_calls + 1
            return setup(...)
          end
        end
        return module
      end
    '';
    script = ''
      assert(_G.telescope_test_setup_calls == 0, "Telescope must stay unloaded before its first entry point")
      local completion = vim.fn.getcompletion("Telescope pterm ", "cmdline")
      assert(vim.tbl_contains(completion, "sessions") and vim.tbl_contains(completion, "grep"),
        "first completion must include the configured pterm subcommands")
      assert(_G.telescope_test_setup_calls == 1, "Telescope setup must run exactly once")
      local telescope = require("telescope")
      for extension, api in pairs({
        live_grep_args = "live_grep_args",
        sonictemplate = "templates",
        projects = "projects",
        ghq = "ghq",
        worktab = "worktab",
      }) do
        assert(package.loaded["telescope._extensions." .. extension], extension .. " was not loaded by the profile")
        assert(type(telescope.extensions[extension][api]) == "function", extension .. " picker API is missing")
      end
      assert(package.loaded["telescope._extensions.ui-select"], "ui-select was not loaded by the profile")
      -- The profile ships fzf-native without changing its existing sorter choice.
      -- Exercise its native library without loading or reconfiguring an extension.
      local fzf = require("fzf_lib")
      local slab, pattern = fzf.allocate_slab(), fzf.parse_pattern("tlscp")
      local score = fzf.get_score("telescope", pattern, slab)
      fzf.free_pattern(pattern)
      fzf.free_slab(slab)
      assert(score > 0, "native fzf matching failed")

      vim.o.columns, vim.o.lines = 120, 40
      vim.cmd.enew()
      local original_win = vim.api.nvim_get_current_win()
      local actions = require("telescope.actions")
      local state = require("telescope.actions.state")
      local items = { { label = "first" }, { label = "second" } }
      local function wait(predicate, message)
        assert(vim.wait(5000, predicate, 10), message)
      end
      local function open()
        vim.cmd.stopinsert()
        local calls = {}
        vim.ui.select(items, {
          prompt = "Telescope selection test:",
          format_item = function(item) return item.label end,
        }, function(item, index)
          calls[#calls + 1] = { item = item, index = index, win = vim.api.nvim_get_current_win() }
        end)
        local picker, prompt
        wait(function()
          prompt = vim.api.nvim_get_current_buf()
          if vim.bo[prompt].filetype ~= "TelescopePrompt" then return false end
          picker = state.get_current_picker(prompt)
          return picker and picker.manager and picker.manager:num_results() == #items
            and picker:get_selection() ~= nil
        end, "vim.ui.select did not open a populated Telescope picker")
        assert(#calls == 0, "selection callback ran before a choice")
        return picker, prompt, calls
      end
      local picker, prompt, calls = open()
      for _ = 1, #items do
        if picker:get_selection().value.idx == 2 then break end
        actions.move_selection_next(prompt)
      end
      assert(picker:get_selection().value.idx == 2, "could not select the second item")
      actions.select_default(prompt)
      wait(function() return #calls == 1 end, "selection callback did not run")
      assert(calls[1].item == items[2] and calls[1].index == 2, "callback lost the selected item or index")
      assert(calls[1].win == original_win, "callback ran before restoring the original window")
      assert(not vim.api.nvim_buf_is_valid(prompt), "selection did not close the picker")

      local _, cancel_prompt, cancelled = open()
      actions.close(cancel_prompt)
      wait(function() return #cancelled == 1 end, "cancellation callback did not run")
      assert(cancelled[1].item == nil and cancelled[1].index == nil, "cancel must return nil item and index")
      assert(cancelled[1].win == original_win, "cancel callback ran before restoring the original window")
      assert(not vim.api.nvim_buf_is_valid(cancel_prompt), "cancel did not close the picker")
      vim.wait(50, function() return false end)
      assert(#calls == 1 and #cancelled == 1, "selection callbacks ran more than once")
      assert(_G.telescope_test_setup_calls == 1, "using pickers must not repeat Telescope setup")
    '';
  };
  tests.telescope-first-ui-select = luaCheck {
    name = "telescope-first-ui-select";
    script = ''
      assert(not package.loaded.telescope, "UI selection must not require an eager Telescope")
      local initial_handler, original_win = vim.ui.select, vim.api.nvim_get_current_win()
      local calls = {}
      vim.ui.select({ "first", "second" }, { prompt = "Cold selection" }, function(item, index)
        calls[#calls + 1] = { item = item, index = index }
      end)
      assert(package.loaded.telescope and vim.ui.select ~= initial_handler,
        "first UI selection did not activate and replace the lazy handler")
      local prompt = vim.api.nvim_get_current_buf()
      assert(vim.bo[prompt].filetype == "TelescopePrompt", "first selection did not open Telescope")
      local state = require("telescope.actions.state")
      local picker = state.get_current_picker(prompt)
      assert(vim.wait(3000, function() return picker:get_selection() ~= nil end, 10),
        "first selection did not produce entries")
      require("telescope.actions").select_default(prompt)
      assert(vim.wait(1000, function() return #calls == 1 end, 10), "first selection callback was lost")
      assert(calls[1].item == "first" and calls[1].index == 1, "first selection payload changed")
      assert(vim.api.nvim_get_current_win() == original_win, "selection did not restore the original window")
    '';
  };
  tests.telescope-first-command = luaCheck {
    name = "telescope-first-command";
    script = ''
      assert(not package.loaded.telescope, "Telescope must remain cold before its command")
      local original_win = vim.api.nvim_get_current_win()
      vim.api.nvim_buf_set_name(0, vim.env.HOME .. "/buffer with spaces.txt")
      vim.cmd("TelescopeBufferName")
      local prompt = vim.api.nvim_get_current_buf()
      assert(vim.bo[prompt].filetype == "TelescopePrompt", "first alias did not open the buffer picker")
      require("telescope.actions").close(prompt)
      assert(vim.api.nvim_get_current_win() == original_win, "first command did not restore its window")
      -- Use the actual upstream parser on the second call, not a loader stub.
      vim.cmd("Telescope buffers initial_mode=normal sort_mru=true")
      prompt = vim.api.nvim_get_current_buf()
      assert(vim.bo[prompt].filetype == "TelescopePrompt", "repeated command did not open a picker")
      local picker = require("telescope.actions.state").get_current_picker(prompt)
      assert(picker.initial_mode == "normal", "command arguments did not reach the picker")
      require("telescope.actions").close(prompt)
      assert(vim.api.nvim_get_current_win() == original_win, "repeated command did not restore its window")
    '';
  };
}
