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
let
  ptermMappingCheck =
    key: picker:
    luaCheck {
      name = "telescope-first-pterm-${picker}";
      preInit = ''
        local original_require = require
        local wrapped = false
        _G.require = function(name)
          local module = original_require(name)
          if name == "pterm" and not wrapped then
            wrapped = true
            -- Keep the real lazy loader, commands and pickers; isolate daemon IO.
            module.list = function() return { "fixture/test session" } end
            module.open = function(name, argv) _G.pterm_created = { name, argv } end
            module.kill = function(name) _G.pterm_killed = name end
            module.is_connected = function() return false end
            module.display_name = function(name) return name end
            module.full_text_ansi = function() return "fixture grep line" end
            module.snapshot_ansi_async = function(_, callback)
              vim.schedule(function() callback("fixture preview") end)
              return { kill = function() end }
            end
          end
          return module
        end
      '';
      script = ''
        assert(not package.loaded.telescope and not package.loaded.pterm,
          "pterm mappings must leave Telescope and pterm cold at startup")
        vim.o.columns, vim.o.lines = 120, 40
        local function open(key, expected)
          vim.cmd.stopinsert()
          local mapping = vim.fn.maparg("<Leader>" .. key, "n", false, true)
          assert(mapping.rhs == "<Cmd>Telescope pterm " .. expected .. "<CR>", "wrong pterm mapping: " .. key)
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Leader>" .. key, true, false, true), "xt", false)
          local prompt, picker
          assert(vim.wait(5000, function()
            prompt = vim.api.nvim_get_current_buf()
            if vim.bo[prompt].filetype ~= "TelescopePrompt" then return false end
            picker = require("telescope.actions.state").get_current_picker(prompt)
            return picker and picker.manager and picker.manager:num_results() == 1
          end, 10), "mapping did not open populated pterm " .. expected)
          assert(picker.prompt_title:find("pterm " .. expected, 1, true), "mapping opened the wrong picker")
          local entry = picker.manager:get_entry(1)
          assert(entry.value == "fixture/test session", "session name changed")
          assert((entry.grep_line == "fixture grep line") == (expected == "grep"), "wrong picker entries")
          require("telescope.actions").close(prompt)
        end
        -- Each check starts with a different mapping before any completion/require.
        open("${key}", "${picker}")
        open("fT", "grep")
        open("ft", "sessions")
        assert(vim.fn.exists(":Template") == 0, "retired Template command is still registered")
        assert(not vim.tbl_contains(vim.fn.getcompletion("Template", "command"), "Template"))
        assert(not vim.tbl_contains(vim.fn.getcompletion("Telescope ", "cmdline"), "sonictemplate"),
          "retired Telescope extension is still offered")
        assert(#vim.api.nvim_get_runtime_file("plugin/sonictemplate.vim", true) == 0)
        assert(#vim.api.nvim_get_runtime_file("lua/telescope/_extensions/sonictemplate.lua", true) == 0)
        local state = require("telescope.actions.state")
        require("telescope").extensions.pterm.sessions({ previewer = false })
        local prompt = vim.api.nvim_get_current_buf()
        local picker = state.get_current_picker(prompt)
        picker:set_prompt("fixture")
        assert(vim.wait(3000, function()
          local entry = state.get_selected_entry()
          return state.get_current_line() == "fixture" and entry and entry.value == "fixture/test session"
        end, 10), "fuzzy session fixture did not match")
        local callback = assert(vim.fn.maparg("<C-o>", "i", false, true).callback)
        callback()
        assert(vim.deep_equal(_G.pterm_created, { "fixture", { "fixture" } }),
          "Ctrl-o must use the prompt instead of opening the fuzzy match")
        require("telescope").extensions.pterm.sessions({ previewer = false, default_text = "fixture" })
        prompt = vim.api.nvim_get_current_buf()
        assert(vim.wait(3000, function()
          local entry = state.get_selected_entry()
          return state.get_current_line() == "fixture" and entry and entry.value == "fixture/test session"
        end, 10))
        local close = assert(vim.fn.maparg("<C-x>", "n", false, true).callback)
        local confirm = vim.fn.confirm
        local prompted = false
        vim.fn.confirm = function(message, _, default)
          prompted = true
          assert(message:find("fixture/test session", 1, true) and default == 2)
          return 2
        end
        close()
        assert(not prompted, "close confirmation must be dispatched")
        assert(vim.wait(3000, function() return prompted end, 10))
        assert(not _G.pterm_killed and vim.api.nvim_get_current_buf() == prompt)
        vim.fn.confirm = function() return 1 end
        close()
        assert(vim.wait(3000, function() return _G.pterm_killed == "fixture/test session" end, 10))
        vim.fn.confirm = confirm
        for _, command in ipairs({ "grep", "sessions" }) do
          assert(vim.tbl_contains(vim.fn.getcompletion("Telescope pterm ", "cmdline"), command))
          vim.cmd("Telescope pterm " .. command .. " previewer=false")
          assert(vim.bo.filetype == "TelescopePrompt", "existing pterm command stopped opening its picker")
          require("telescope.actions").close(vim.api.nvim_get_current_buf())
        end
      '';
    };
in
{
  doc = ''
    Telescope 本体と拡張をまとめ、picker と選択 UI の設定を共有する。

    `<Leader>ft` は `:Telescope pterm sessions`、`<Leader>fT` は `:Telescope pterm grep` を開く。
    pterm のセッション一覧、worktab、Track のタイトル・本文検索では、`<C-o>` で候補ではなく入力欄を使う。
    pterm では `name command args...` も使える。worktab と pterm のセッション一覧では `<C-x>` で選択中の項目を閉じる。
    pterm のセッション終了は実行中のプロセスも止めるので確認を表示する。

    通常の files / grep では登録済みの子 worktree を除外する（選択中の worktree 自体は検索可能）。
    `<Leader>fw` / `:TelescopeWorktrees` は `git gtr list --porcelain` から選択し、Enter でファイル検索する。候補がない場合は入力したブランチ名で `git gtr new --yes` を実行し、作成先のファイル検索を開く（空入力は閉じる）。cwd の切替は既存の project.nvim によるファイル選択時の自動移動に任せる。
    `<Leader>fP` の ghq プロジェクト一覧では、名前が `-worktrees` で終わるディレクトリとその配下を非表示にする。worktree 専用 picker は対象外。
    worktree 一覧では `prunable` を他の一致候補より下に表示する（検索中も同様）。登録の削除は行わない。
    ghq 配下の検索では ghq 登録リポジトリも確認する。git-gtr は extraPackages に同梱する。`git gtr new` では標準の隣接 `<repo>-worktrees/` 配下に作成し、既存の `gtr.worktrees.dir` 設定は尊重する。

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

    # telescope-mr

    ## 概要
    vim-mr の履歴を Telescope で選択する。

    ## 使い方
    `:Telescope mr mru` / `mrw` / `mrr` / `mrd` で利用する。
    `<Leader>fru` / `frr` / `frw` は現在のディレクトリ内、
    `<Leader>Fru` / `Frr` / `Frw` は全体の履歴を表示する。

    ## 要件
    Telescope と vim-mr の Vimscript API を使用する。Denops / Deno は不要。

    ## 出典
    [固定リビジョンの実装](https://github.com/ttak0422/telescope-mr/blob/eea3fd6ae1eb41c306321d0ac3dfcbf2ad666558/lua/telescope/_extensions/mr.lua)

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
    "TelescopeWorktrees"
  ];
  onModules = [ "telescope" ];
  packages = with sources; [
    telescope-nvim
    (telescope-mr.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ../support/telescope/mr-filename-first.patch ];
    }))
    telescope-fzf-native-nvim
    telescope-ghq-nvim
    telescope-live-grep-args-nvim
    telescope-ui-select-nvim
  ];
  dependPlugins = [
    definitions.vim-mr
    definitions.plenary-nvim
    definitions.project-nvim
    definitions.worktab-nvim
    definitions.pterm
    definitions.track
  ];
  extraPackages = with pkgs; [
    ripgrep
    ghq
    git-gtr
  ];
  config = luaConfig (
    # lua
    ''
      local worktrees = dofile("${../support/telescope/worktrees.lua}")
      package.loaded["config.telescope_worktrees"] = worktrees
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
        pickers = {
          -- Filename-first belongs to filename searches, not repositories or grep.
          find_files = { find_command = worktrees.find_command, path_display = { "filename_first" } },
          git_files = { path_display = { "filename_first" } },
          oldfiles = { path_display = { "filename_first" } },
          buffers = { path_display = { "filename_first" } },
          live_grep = { additional_args = worktrees.grep_args },
          grep_string = { additional_args = worktrees.grep_args },
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
            additional_args = worktrees.grep_args,
          },
        },
      })
      for _, extension in ipairs({ "mr", "ui-select", "live_grep_args", "projects", "ghq", "worktab", "track" }) do
        telescope.load_extension(extension)
      end
      -- Keep ghq's native display/actions; filter only its project list, not
      -- project.nvim root detection or the dedicated worktree picker.
      local ghq = telescope.extensions.ghq
      local ghq_list = ghq.list
      local function configured_ghq(opts)
        opts = vim.tbl_extend("force", {}, opts or {})
        opts.file_ignore_patterns = vim.list_extend(
          vim.deepcopy(opts.file_ignore_patterns or require("telescope.config").values.file_ignore_patterns or {}),
          { "%-worktrees/", "%-worktrees$" }
        )
        return ghq_list(opts)
      end
      ghq.ghq = configured_ghq
      ghq.list = configured_ghq

      telescope.load_extension("pterm")
      dofile("${../support/telescope/open-from-prompt.lua}").setup(telescope)

      vim.api.nvim_create_user_command("TelescopeWorktrees", function() worktrees.pick() end, {})

      vim.api.nvim_create_user_command("TelescopeBuffer", function()
        builtin.live_grep({ grep_open_files = true })
      end, {})
      vim.api.nvim_create_user_command("TelescopeBufferName", function()
        builtin.buffers({ sort_mru = true, ignore_current_buffer = false })
      end, {})
    ''
  );
  tests.telescope-first-pterm-grep = ptermMappingCheck "fT" "grep";
  tests.telescope-first-pterm-sessions = ptermMappingCheck "ft" "sessions";
  tests.telescope-open-from-prompt = luaCheck {
    name = "telescope-open-from-prompt";
    script = builtins.readFile ../checks/telescope-open-from-prompt.lua;
  };
  tests.telescope-path-display-scope = luaCheck {
    name = "telescope-path-display-scope";
    script = builtins.readFile ../checks/telescope-path-display-scope.lua;
  };
  tests.telescope-ghq-worktree-filter = luaCheck {
    name = "telescope-ghq-worktree-filter";
    script = ''
      local telescope = require('telescope')
      local root = vim.fn.tempname()
      vim.fn.mkdir(root, 'p')
      local bin = root .. '/ghq-fixture'
      vim.fn.writefile({
        '#!/bin/sh',
        [[printf '%s\n' '/projects/main' '/projects/repo-worktrees' '/projects/repo-worktrees/feature' '/projects/nested/repo-worktrees/a/b' '/projects/repo-worktrees-backup' '/projects/worktrees' '/projects/ignored/repo']],
      }, bin)
      vim.fn.setfperm(bin, 'rwx------')
      local state, actions = require('telescope.actions.state'), require('telescope.actions')
      local builtin = require('telescope.builtin')
      local original_files, selected = builtin.git_files, nil
      builtin.git_files = function(opts) selected = opts.cwd end
      local original_patterns = require('telescope.config').values.file_ignore_patterns
      require('telescope.config').values.file_ignore_patterns = { '/ignored/' }
      local worktree_picker = require('config.telescope_worktrees').pick
      vim.o.columns, vim.o.lines = 120, 40
      for _, alias in ipairs({ 'ghq', 'list' }) do
        local opts = { bin = bin, previewer = false }
        if alias == 'list' then opts.file_ignore_patterns = { '/ignored/' } end
        telescope.extensions.ghq[alias](opts)
        local picker, prompt
        assert(vim.wait(3000, function()
          if vim.bo.filetype ~= 'TelescopePrompt' then return false end
          prompt = vim.api.nvim_get_current_buf()
          picker = state.get_current_picker(prompt)
          return picker.manager and picker.manager:num_results() == 3 and state.get_selected_entry() ~= nil
        end, 10))
        local results = {}
        for entry in picker.manager:iter() do results[entry.value] = true end
        assert(results['/projects/main'])
        assert(results['/projects/repo-worktrees-backup'])
        assert(results['/projects/worktrees'])
        assert(opts.file_ignore_patterns == nil or #opts.file_ignore_patterns == 1, 'caller options mutated')
        assert(#require('telescope.config').values.file_ignore_patterns == 1, 'global filters mutated')
        -- Selection still calls the upstream git-files action.
        selected = nil
        actions.select_default(prompt)
        assert(selected and results[selected], 'native ghq selection changed')
        if vim.bo.filetype == 'TelescopePrompt' then actions.close(vim.api.nvim_get_current_buf()) end
      end
      assert(require('config.telescope_worktrees').pick == worktree_picker, 'worktree picker changed')
      -- The same path remains visible in an ordinary picker without the local ghq filter.
      require('telescope.pickers').new({}, {
        finder = require('telescope.finders').new_table({ results = { '/projects/repo-worktrees/feature' } }),
        sorter = require('telescope.config').values.generic_sorter({}),
      }):find()
      assert(vim.wait(3000, function()
        local entry = state.get_selected_entry()
        return vim.bo.filetype == 'TelescopePrompt' and entry and entry.value == '/projects/repo-worktrees/feature'
      end, 10))
      actions.close(vim.api.nvim_get_current_buf())
      builtin.git_files = original_files
      require('telescope.config').values.file_ignore_patterns = original_patterns
      vim.fn.delete(root, 'rf')
      print('project worktree filter tests passed')
    '';
  };
  tests.telescope-worktree-order = luaCheck {
    name = "telescope-worktree-order";
    script = ''
      require('telescope')
      local worktrees = require('config.telescope_worktrees')
      local root = vim.fn.tempname()
      vim.fn.mkdir(root, 'p')
      local repo = root .. '/repo'
      local function run(args, cwd)
        local result = vim.system(args, { cwd = cwd, text = true }):wait()
        assert(result.code == 0, result.stderr)
        return result.stdout
      end
      run({ 'git', 'init', '-qb', 'main', repo })
      run({ 'git', '-c', 'user.name=Test', '-c', 'user.email=test@example.invalid', 'commit', '--allow-empty', '-qm', 'initial' }, repo)
      local live = root .. '/z-live'
      run({ 'git', 'worktree', 'add', '-qb', 'match-live', live }, repo)
      for _, name in ipairs({ 'match', 'onlystale' }) do
        local path = root .. '/a-' .. name
        run({ 'git', 'worktree', 'add', '-qb', name, path }, repo)
        vim.fn.delete(path, 'rf')
      end
      local entries = assert(worktrees.parse(run({ 'git', 'gtr', 'list', '--porcelain' }, repo)))
      local stale = 0
      for _, entry in ipairs(entries) do if entry.status == 'prunable' then stale = stale + 1 end end
      assert(stale == 2, 'pinned gtr must expose Git prunable status')
      local conf = require('telescope.config').values
      local original_sorter = conf.generic_sorter
      local factories = { original_sorter }
      require('telescope').load_extension('fzf')
      factories[#factories + 1] = conf.generic_sorter
      local state, actions = require('telescope.actions.state'), require('telescope.actions')
      local builtin = require('telescope.builtin')
      local original_files, opened = builtin.find_files, nil
      builtin.find_files = function(opts) opened = opts.cwd end
      local notify, notices = vim.notify, {}
      vim.notify = function(message) notices[#notices + 1] = message end
      vim.o.columns, vim.o.lines = 140, 40
      for _, factory in ipairs(factories) do
        conf.generic_sorter = factory
        worktrees.pick({ cwd = repo, sorting_strategy = 'ascending' })
        assert(vim.wait(3000, function() return vim.bo.filetype == 'TelescopePrompt' and state.get_selected_entry() ~= nil end, 10))
        local prompt = vim.api.nvim_get_current_buf()
        local picker = state.get_current_picker(prompt)
        for _, case in ipairs({ { "", 4 }, { 'match', 2 }, { 'onlystale', 1 }, { 'zzzznonexistent', 0 }, { "", 4 } }) do
          picker:set_prompt(case[1])
          assert(vim.wait(3000, function()
            return state.get_current_line() == case[1] and picker.manager and picker.manager:num_results() == case[2]
          end, 10), 'unexpected match count for ' .. case[1])
          local seen_stale = false
          for entry in picker.manager:iter() do
            if entry.value.status == 'prunable' then seen_stale = true
            else assert(not seen_stale, 'healthy entry ranked below prunable') end
          end
          if case[1] == 'match' then
            assert(state.get_selected_entry().value.path == live, 'strong stale match outranked healthy match')
          elseif case[1] == 'onlystale' then
            opened = nil
            actions.select_default(prompt)
            assert(opened == nil and vim.bo.filetype == 'TelescopePrompt')
            assert(notices[#notices]:find('Worktree no longer exists:', 1, true))
          elseif case[2] == 0 then
            assert(state.get_selected_entry() == nil, 'no-match must remain eligible for creation')
          end
        end
        picker:set_prompt('match-live')
        assert(vim.wait(3000, function()
          local entry = state.get_selected_entry()
          return picker.manager:num_results() == 1 and entry and entry.value.path == live
        end, 10))
        opened = nil
        actions.select_default(prompt)
        assert(opened == live, 'healthy selection changed')
      end
      conf.generic_sorter, builtin.find_files, vim.notify = original_sorter, original_files, notify
      assert(run({ 'git', 'worktree', 'list', '--porcelain' }, repo):find('prunable', 1, true), 'sorting must not prune registrations')
      vim.fn.delete(root, 'rf')
    '';
  };
  tests.telescope-gtr-worktrees = luaCheck {
    name = "telescope-gtr-worktrees";
    script = ''
      require("telescope")
      local worktrees = require('config.telescope_worktrees')
      local root = vim.fn.tempname()
      vim.fn.mkdir(root, 'p')
      local function run(args, cwd)
        local result = vim.system(args, { cwd = cwd, text = true }):wait()
        assert(result.code == 0, result.stderr)
        return result.stdout
      end
      local repo = root .. '/repo space'
      run({ 'git', 'init', '-q', repo })
      run({ 'git', '-c', 'user.name=Test', '-c', 'user.email=test@example.invalid', 'commit', '--allow-empty', '-qm', 'initial' }, repo)
      local wt = repo .. '/custom[tree]$HOME/feature'
      run({ 'git', 'worktree', 'add', '-qb', 'feature', wt }, repo)
      vim.fn.writefile({ 'needle' }, repo .. '/main.txt')
      vim.fn.writefile({ 'needle' }, wt .. '/linked.txt')
      vim.fn.mkdir(repo .. '/ordinary-worktrees', 'p')
      vim.fn.writefile({ 'needle' }, repo .. '/ordinary-worktrees/keep.txt')
      local files = run(worktrees.find_command({ cwd = repo }), repo)
      assert(files:find('main.txt', 1, true) and files:find('keep.txt', 1, true))
      assert(not files:find('linked.txt', 1, true), files)
      assert(run(worktrees.find_command({ cwd = wt }), wt):find('linked.txt', 1, true))
      local grep = { 'rg', '--files-with-matches', 'needle' }
      vim.list_extend(grep, worktrees.grep_args({ cwd = repo }))
      assert(not run(grep, repo):find('linked.txt', 1, true))
      -- Enumerate global ghq roots without directory naming assumptions.
      local original_system, original_executable = vim.system, vim.fn.executable
      vim.fn.executable = function(name) if name == 'ghq' then return 1 end; return original_executable(name) end
      vim.system = function(args, opts)
        if args[1] == 'ghq' then return { wait = function() return { code = 0, stdout = repo .. '\n' } end } end
        return original_system(args, opts)
      end
      assert(not run(worktrees.find_command({ cwd = root }), root):find('linked.txt', 1, true))
      vim.system, vim.fn.executable = original_system, original_executable
      local _, slash = worktrees.roots('/')
      assert(slash == '/')
      local entries = assert(worktrees.parse(repo .. '\tmain\tmain\n' .. wt .. '\tfeature\tclean\n'))
      assert(#entries == 2 and entries[2].path == wt)
      assert(worktrees.parse('/bad\tpath\tbranch\tclean\n') == nil)
      -- The Telescope package must supply gtr, not rely on a user's shell PATH.
      assert(vim.fn.executable('git-gtr') == 1, 'git-gtr must be bundled in extraPackages')
      local registered = assert(worktrees.parse(run({ 'git', 'gtr', 'list', '--porcelain' }, repo)))
      assert(#registered == 2)
      assert(vim.tbl_contains(vim.tbl_map(function(entry) return entry.path end, registered), wt))
      -- Isolate picker selection from gtr ordering while exercising real Telescope.
      vim.o.columns, vim.o.lines = 120, 40
      local builtin = require('telescope.builtin')
      local original_files, selected = builtin.find_files, nil
      builtin.find_files = function(opts) selected = opts.cwd end
      vim.system = function(args, opts)
        if args[2] == 'gtr' then return { wait = function() return { code = 0, stdout = wt .. '\tfeature\tclean\n' } end } end
        return original_system(args, opts)
      end
      local cwd = vim.fn.getcwd()
      worktrees.pick({ cwd = repo })
      local state, actions = require('telescope.actions.state'), require('telescope.actions')
      local prompt
      assert(vim.wait(3000, function()
        prompt = vim.api.nvim_get_current_buf()
        return vim.bo[prompt].filetype == 'TelescopePrompt' and state.get_selected_entry() ~= nil
      end, 10))
      for _, mode in ipairs({ 'i', 'n' }) do
        for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(prompt, mode)) do
          assert(mapping.lhs ~= '<C-O>', 'worktree picker must not map Ctrl-o to cwd changes')
          assert(mapping.lhs ~= '<C-G>', 'worktree picker must not map Ctrl-g to a custom action')
        end
      end
      actions.select_default(prompt)
      assert(selected == wt and vim.fn.getcwd() == cwd)
      worktrees.pick({ cwd = repo })
      assert(vim.wait(3000, function() return vim.bo.filetype == 'TelescopePrompt' end, 10))
      actions.close(vim.api.nvim_get_current_buf())
      assert(vim.fn.getcwd() == cwd)
      vim.system, builtin.find_files = original_system, original_files
      -- Match existing pterm semantics: only no candidate + Enter creates a named item.
      local remote = root .. '/remote.git'
      run({ 'git', 'init', '--bare', '-q', remote })
      run({ 'git', 'remote', 'add', 'origin', remote }, repo)
      run({ 'git', 'push', '-q', 'origin', 'HEAD:main' }, repo)
      run({ 'git', 'symbolic-ref', 'HEAD', 'refs/heads/main' }, remote)
      local get_entry, get_line = state.get_selected_entry, state.get_current_line
      local notify, notices = vim.notify, {}
      vim.notify = function(message) notices[#notices + 1] = message end
      local function enter_missing(name)
        worktrees.pick({ cwd = repo })
        assert(vim.wait(3000, function() return vim.bo.filetype == 'TelescopePrompt' end, 10))
        state.get_selected_entry = function() return nil end
        state.get_current_line = function() return name end
        actions.select_default(vim.api.nvim_get_current_buf())
        state.get_selected_entry, state.get_current_line = get_entry, get_line
      end
      builtin.find_files = function(opts) selected = opts.cwd end
      local before = run({ 'git', 'worktree', 'list', '--porcelain' }, repo)
      enter_missing("")
      assert(run({ 'git', 'worktree', 'list', '--porcelain' }, repo) == before)
      for _, invalid in ipairs({ '-bad-option', 'bad name', '@{-1}', '$(touch injected)' }) do
        enter_missing(invalid)
        assert(vim.bo.filetype == 'TelescopePrompt')
        actions.close(vim.api.nvim_get_current_buf())
      end
      assert(run({ 'git', 'worktree', 'list', '--porcelain' }, repo) == before)
      selected = nil
      -- A shell metacharacter is a literal ref character, never shell syntax.
      worktrees.pick({ cwd = repo })
      assert(vim.wait(3000, function() return vim.bo.filetype == 'TelescopePrompt' end, 10))
      local create_prompt = vim.api.nvim_get_current_buf()
      state.get_current_picker(create_prompt):set_prompt('new;literal')
      assert(vim.wait(3000, function() return state.get_current_line() == 'new;literal' and state.get_selected_entry() == nil end, 10))
      actions.select_default(create_prompt)
      assert(vim.wait(10000, function() return selected ~= nil end, 10), vim.inspect(notices))
      assert(selected == vim.trim(run({ 'git', 'gtr', 'go', 'new;literal' }, repo)))
      assert(vim.fn.isdirectory(selected) == 1)
      -- An existing local branch without a worktree is supported by gtr.
      run({ 'git', 'branch', 'existing-local' }, repo)
      selected = nil
      enter_missing('existing-local')
      assert(vim.wait(10000, function() return selected ~= nil end, 10), vim.inspect(notices))
      assert(selected == vim.trim(run({ 'git', 'gtr', 'go', 'existing-local' }, repo)))
      -- A native gtr failure must not open a file picker or report success.
      local count = #notices
      vim.system = function(args, opts, callback)
        if args[2] == 'gtr' and args[3] == 'new' then
          callback({ code = 1, stderr = 'creation denied', stdout = "" })
          return {}
        end
        return original_system(args, opts, callback)
      end
      selected = nil
      enter_missing('will-fail')
      assert(vim.wait(3000, function() return #notices >= count + 2 end, 10))
      assert(selected == nil and notices[#notices]:find('creation failed', 1, true))
      vim.system, builtin.find_files, vim.notify = original_system, original_files, notify
      vim.fn.delete(root, 'rf')
    '';
  };
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
        projects = "projects",
        ghq = "ghq",
        worktab = "worktab",
        mr = "mru",
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
  tests.telescope-mr-without-denops = luaCheck {
    name = "telescope-mr-without-denops";
    preInit = ''
      vim.g["mr#delay"] = 20
    '';
    script = ''
      -- Exercise the real profile, recorders, mappings and pickers with isolated state.
      local function no_denops()
        assert(#vim.api.nvim_get_runtime_file('plugin/denops.vim', true) == 0)
        assert(vim.fn.exists('*denops#request') == 0)
        for _, script in ipairs(vim.fn.getscriptinfo()) do
          assert(not script.name:find('/denops[/.]'), script.name)
        end
      end
      no_denops()
      assert(vim.g.loaded_mr == 1, 'MR must record eagerly')
      assert(not package.loaded.telescope, 'recording must not load Telescope')
      -- Remove Deno's executable directory while preserving the other profile tools.
      vim.env.PATH = table.concat(vim.tbl_filter(function(dir)
        return vim.fn.executable(dir .. '/deno') == 0
      end, vim.split(vim.env.PATH, ':', { plain = true })), ':')
      assert(vim.fn.executable('deno') == 0)
      local root = assert(vim.uv.fs_realpath(vim.env.HOME)) .. '/MR-fixtures'
      local repo, other = root .. '/repo', root .. '/repo-other'
      for _, dir in ipairs({ repo .. '/.git', repo .. '/space dir', other .. '/.git' }) do
        vim.fn.mkdir(dir, 'p')
      end
      local file, outside = repo .. '/space dir/file with spaces.txt', other .. '/outside.txt'
      vim.fn.writefile({ 'inside' }, file)
      vim.fn.writefile({ 'repository marker' }, repo .. '/plain.txt')
      vim.fn.writefile({ 'outside' }, outside)
      local function list(kind) return vim.fn['mr#' .. kind .. '#list']() end
      local function wait(predicate, message)
        assert(vim.wait(3000, predicate, 10), message)
      end
      local function visit(path)
        vim.cmd.edit(vim.fn.fnameescape(path))
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'saved' })
        vim.cmd.write()
      end
      vim.cmd.cd(vim.fn.fnameescape(other))
      visit(outside)
      -- Upstream MRR's finddir search does not escape spaces in parent paths.
      -- Record the repository from a plain path; exercise space-safe MRU/MRW below.
      visit(repo .. '/plain.txt')
      vim.cmd.cd(vim.fn.fnameescape(repo .. '/space dir'))
      visit(file)
      local wanted = { mru = file, mrw = file, mrr = repo, mrd = repo .. '/space dir' }
      for kind, path in pairs(wanted) do
        wait(function() return vim.tbl_contains(list(kind), path) end, kind .. ': missing automatic record')
      end
      assert(not package.loaded.telescope, 'file events must not activate Telescope')
      -- Stop writers before checking persisted stale entries and deletion.
      for kind in pairs(wanted) do vim.fn['mr#' .. kind .. '#stop_recording']() end
      local filename = vim.fn.expand(vim.g['mr#mru#filename'])
      vim.fn.writefile({ file, outside, root .. '/missing.txt' }, filename)
      assert(vim.deep_equal(list('mru'), { file, outside }), 'stale files must be filtered')
      vim.cmd.cd(vim.fn.fnameescape(repo))
      vim.o.lines, vim.o.columns = 60, 220
      local function check_picker(open, expected, rejected, kind)
        vim.cmd.stopinsert()
        open()
        local prompt = vim.api.nvim_get_current_buf()
        assert(vim.bo[prompt].filetype == 'TelescopePrompt', 'MR entry point did not open Telescope')
        local picker = require('telescope.actions.state').get_current_picker(prompt)
        wait(function() return picker.manager and picker.manager:num_results() > 0 end, 'MR picker has no entries')
        local values = {}
        for entry in picker.manager:iter() do
          values[#values + 1] = entry.value
          assert(entry.ordinal == entry.value, 'MR search ordinal must remain the full path')
          if kind == 'mru' or kind == 'mrw' then
            local display, highlights = entry:display()
            local basename = vim.fn.fnamemodify(entry.value, ':t')
            assert(vim.startswith(display, basename), 'MR basename must be first: ' .. display)
            if entry.value == file then
              assert(display == basename .. ' space dir', 'MR dirname must follow basename: ' .. display)
              assert(vim.deep_equal(highlights, { { { #basename, #display }, 'TelescopeResultsComment' } }),
                'MR directory styling must cover the visible directory')
            end
          elseif kind then
            assert(entry.display == entry.value, 'MR repository/directory display must not change')
          end
        end
        for _, value in ipairs(expected) do
          assert(vim.tbl_contains(values, value), 'missing picker entry: ' .. value)
        end
        for _, value in ipairs(rejected or {}) do
          assert(not vim.tbl_contains(values, value), 'unexpected picker entry: ' .. value)
        end
        require('telescope.actions').close(prompt)
      end
      local function mapping(lhs)
        local map = vim.fn.maparg(lhs, 'n', false, true)
        assert(type(map.callback) == 'function', 'missing mapping: ' .. lhs)
        return map.callback
      end
      -- The first MR mapping activates the lazy Telescope cartridge. Lua options keep
      -- spaces in cwd intact and avoid command-line escaping/parsing differences.
      for key, kind in pairs({ u = 'mru', w = 'mrw', r = 'mrr' }) do
        vim.cmd.cd(vim.fn.fnameescape(repo))
        local inside = kind == 'mrr' and repo or file
        local elsewhere = kind == 'mrr' and other or outside
        check_picker(mapping('<Leader>fr' .. key), { inside }, { elsewhere, root .. '/missing.txt' }, kind)
        check_picker(mapping('<Leader>Fr' .. key), { inside, elsewhere }, nil, kind)
      end
      local telescope = require('telescope')
      for kind, path in pairs(wanted) do
        check_picker(function() telescope.extensions.mr[kind]({ previewer = false }) end, { path }, nil, kind)
      end
      vim.cmd('Telescope mr mru previewer=false')
      assert(vim.bo.filetype == 'TelescopePrompt', 'Telescope MR command failed')
      require('telescope.actions').close(vim.api.nvim_get_current_buf())
      for kind, path in pairs(wanted) do
        vim.fn['mr#' .. kind .. '#delete'](path)
        wait(function() return not vim.tbl_contains(list(kind), path) end, kind .. ': delete failed')
      end
      no_denops()
      assert(vim.fn.executable('deno') == 0)
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
