{ sources, luaConfig, luaCheck }:
{
  plugin = sources.resession-nvim;
  lazy = true;
  onCommands = [ "WorktreeSessionSave" "WorktreeSessionLoad" ];
  doc = ''
    # resession.nvim

    `:WorktreeSessionSave` は現在のタブだけを Git worktree ごとの一枠に保存する。
    worktree はウィンドウの `:lcd` ではなくタブの cwd（`:tcd`）から解決する。
    `:WorktreeSessionLoad` は既存の Telescope-backed `vim.ui.select` で実パスを選び、
    他のタブを保持して復元する。空の使い捨てタブは上流が再利用する場合がある。
    自動復元・自動保存・削除コマンドは追加しない。

    保存先は `stdpath("data")/worktree-sessions`（NVIM_APPNAME ごとに分離）。
    canonical worktree root の SHA-256 をファイル名に使い、Git の管理ディレクトリ情報を
    セッション内の拡張データに保存する。削除・置換された worktree は再保存が必要。

    公開 save_tab/list/load/extension API を使用する。読み込み前の検証だけは固定版の
    `resession.util.get_session_file` / `resession.files.load_json_file` と JSON レイアウトに依存する。
    pin 更新時は inline checks で再検証する。
    [上流（固定リビジョン）](https://github.com/stevearc/resession.nvim/tree/0983fbdd3fe938c80fb7dd33817f08f428426ac8)
  '';
  config = luaConfig (
    # lua
    ''
      local resession = require("resession")
      local dir = "worktree-sessions"
      local saving_identity
      -- Public extension API keeps identity in the session, without a second index.
      package.preload["resession.extensions.worktree_identity"] = function()
        return { on_save = function() return saving_identity end }
      end
      resession.setup({
        dir = dir,
        autosave = { enabled = false },
        -- Tab sessions include displayed buffers, never unrelated tabs' buffers.
        tab_buf_filter = function() return false end,
        extensions = { worktree_identity = { enable_in_tab = true } },
      })
      local function warn(message)
        vim.notify("Worktree session: " .. message, vim.log.levels.WARN)
      end
      local function git(cwd, flag)
        local result = vim.system({ "git", "-C", cwd, "rev-parse", "--path-format=absolute", flag },
          { text = true }):wait()
        if result.code == 0 then return vim.trim(result.stdout) end
      end
      local function identity(cwd)
        if type(cwd) ~= "string" or vim.fn.isdirectory(cwd) ~= 1 then return end
        local root = git(cwd, "--show-toplevel")
        root = root and vim.uv.fs_realpath(root)
        if not root then return end
        local git_dir = git(root, "--absolute-git-dir")
        local common_dir = git(root, "--git-common-dir")
        git_dir = git_dir and vim.uv.fs_realpath(git_dir)
        common_dir = common_dir and vim.uv.fs_realpath(common_dir)
        local stat = git_dir and vim.uv.fs_stat(git_dir)
        if not stat or not common_dir then return end
        return { root = root, git_dir = git_dir, common_dir = common_dir,
          git_dir_id = tostring(stat.dev) .. ":" .. tostring(stat.ino) }
      end
      -- Pinned internal read APIs: inspect before load can create a tab or change options.
      local function read(name)
        local ok, data = pcall(function()
          local file = require("resession.util").get_session_file(name, dir)
          return require("resession.files").load_json_file(file)
        end)
        if ok and type(data) == "table" and data.tab_scoped == true
          and type(data.tabs) == "table" and #data.tabs == 1
          and type(data.worktree_identity) == "table"
          and type(data.worktree_identity.root) == "string"
          and vim.fn.sha256(data.worktree_identity.root) == name then
          return data
        end
      end
      local function valid_cwds(layout)
        if not layout then return true end
        if layout[1] == "leaf" then
          local cwd = layout[2].cwd
          return not cwd or vim.fn.isdirectory(cwd) == 1
        end
        for _, child in ipairs(layout[2]) do
          if not valid_cwds(child) then return false end
        end
        return true
      end
      vim.api.nvim_create_user_command("WorktreeSessionSave", function()
        -- -1 ignores the current window's :lcd; 0 selects the current tab.
        local current = identity(vim.fn.getcwd(-1, 0))
        if not current then
          warn("outside Git. Set :tcd to a Git worktree, then run :WorktreeSessionSave.")
          return
        end
        saving_identity = current
        local ok, err = pcall(resession.save_tab, vim.fn.sha256(current.root),
          { dir = dir, notify = false, attach = false })
        saving_identity = nil
        if not ok then warn("save failed: " .. tostring(err)); return end
        vim.notify("Saved worktree tab: " .. current.root)
      end, { desc = "Save this tab in its Git worktree session slot" })
      vim.api.nvim_create_user_command("WorktreeSessionLoad", function()
        local items = {}
        for _, name in ipairs(resession.list({ dir = dir })) do
          if #name == 64 and name:match("^%x+$") then
            local data = read(name)
            if data then items[#items + 1] = { name = name, root = data.worktree_identity.root } end
          end
        end
        table.sort(items, function(a, b) return a.root < b.root end)
        if #items == 0 then warn("no saved tabs. Use :WorktreeSessionSave inside Git first."); return end
        vim.ui.select(items, {
          prompt = "Load worktree tab",
          format_item = function(item) return item.root end,
        }, function(item)
          if not item then return end
          -- Reread and revalidate after selection: the root may disappear while the picker is open.
          local data = read(item.name)
          local saved = data and data.worktree_identity
          if not saved or not vim.deep_equal(identity(saved.root), saved) then
            warn("worktree is missing or changed: " .. item.root .. ". Recreate it and save a new tab session.")
            return
          end
          local tab = data.tabs[1]
          if type(tab.cwd) ~= "string" or vim.fn.isdirectory(tab.cwd) ~= 1 or not valid_cwds(tab.wins) then
            warn("a saved cwd is missing for " .. item.root .. ". Save a new tab session.")
            return
          end
          resession.load(item.name, { dir = dir, reset = false, attach = false })
        end)
      end, { desc = "Choose a saved Git worktree tab session" })
    ''
  );
  tests.resession-worktree-tabs = luaCheck {
    name = "resession-worktree-tabs";
    ui = true;
    script = ''
      local function run(args, cwd)
        local result = vim.system(args, { cwd = cwd, text = true }):wait()
        assert(result.code == 0, result.stderr)
        return vim.trim(result.stdout)
      end
      local function wait(predicate)
        assert(vim.wait(5000, predicate, 10), "worktree session picker timed out")
      end
      local notices, notify = {}, vim.notify
      vim.notify = function(message) notices[#notices + 1] = message end
      -- First command loads the lazy plugin, but neither restores nor opens a picker.
      vim.cmd.WorktreeSessionLoad()
      local resession = require("resession")
      assert(not require("resession.config").autosave.enabled)
      assert(#vim.api.nvim_get_autocmds({ group = "ResessionAutosave" }) == 0)
      assert(#resession.list({ dir = "worktree-sessions" }) == 0)
      assert(not package.loaded.telescope, "empty session list must not load Telescope")
      local data_dir = vim.fn.stdpath("data") .. "/worktree-sessions"
      assert(vim.fn.stdpath("data"):find(vim.env.NVIM_APPNAME, 1, true))
      local root = vim.fn.tempname() .. " session fixtures"
      vim.fn.mkdir(root, "p")
      root = assert(vim.uv.fs_realpath(root))
      local repo, a, b = root .. "/repo", root .. "/a/b_c", root .. "/a_b/c"
      run({ "git", "init", "-q", "-b", "main", repo })
      vim.fn.writefile({ "first" }, repo .. "/first.txt")
      vim.fn.writefile({ "second" }, repo .. "/second.txt")
      run({ "git", "add", "." }, repo)
      run({ "git", "-c", "user.name=Session Test", "-c", "user.email=session@example.invalid",
        "commit", "-qm", "fixture" }, repo)
      run({ "git", "worktree", "add", "-qb", "first", a }, repo)
      run({ "git", "worktree", "add", "-qb", "second", b }, repo)
      vim.fn.mkdir(a .. "/subdir", "p")
      assert(a:gsub("/", "_") == b:gsub("/", "_"), "fixture must exercise raw path collisions")
      local key_a, key_b = vim.fn.sha256(a), vim.fn.sha256(b)
      assert(key_a ~= key_b)
      local function read(key)
        return vim.json.decode(table.concat(vim.fn.readfile(data_dir .. "/" .. key .. ".json"), "\n"))
      end
      local function snapshot()
        return { tabs = vim.api.nvim_list_tabpages(), tab = vim.api.nvim_get_current_tabpage(),
          win = vim.api.nvim_get_current_win(), buf = vim.api.nvim_get_current_buf(),
          cwd = vim.fn.getcwd(), tab_cwd = vim.fn.getcwd(-1, 0), global_cwd = vim.fn.getcwd(-1, -1),
          eventignore = vim.o.eventignore, shortmess = vim.o.shortmess }
      end
      local function unchanged(before) assert(vim.deep_equal(before, snapshot()), vim.inspect(snapshot())) end
      local function save_without_chdir()
        local before = snapshot()
        vim.cmd.WorktreeSessionSave()
        unchanged(before)
      end
      -- Tab context wins over a displayed file's repository and the current window's :lcd.
      vim.cmd.tabnew()
      vim.cmd.edit(vim.fn.fnameescape(a .. "/first.txt"))
      vim.cmd.vsplit(vim.fn.fnameescape(a .. "/second.txt"))
      vim.cmd.tcd(vim.fn.fnameescape(a .. "/subdir"))
      vim.cmd.lcd(vim.fn.fnameescape(b))
      save_without_chdir()
      assert(read(key_a).tabs[1].cwd == a .. "/subdir")
      assert(read(key_a).worktree_identity.root == a)
      assert(vim.fn.filereadable(data_dir .. "/" .. key_b .. ".json") == 0)
      -- Saving via a symlink overwrites the canonical root's single slot.
      local alias = root .. "/alias"
      assert(vim.uv.fs_symlink(a, alias))
      vim.cmd.tcd(vim.fn.fnameescape(alias))
      save_without_chdir()
      assert(#resession.list({ dir = "worktree-sessions" }) == 1)
      assert(read(key_a).worktree_identity.root == a)
      vim.cmd.tabnew()
      vim.cmd.edit(vim.fn.fnameescape(b .. "/second.txt"))
      vim.cmd.tcd(vim.fn.fnameescape(b))
      save_without_chdir()
      local saved_b = read(key_b)
      assert(#saved_b.buffers == 1 and saved_b.buffers[1].name == b .. "/second.txt")
      assert(#resession.list({ dir = "worktree-sessions" }) == 2)
      -- Even a Git buffer cannot turn an outside-Git tab context into a save target.
      vim.cmd.tcd(vim.fn.fnameescape(root))
      save_without_chdir()
      assert(notices[#notices]:find("Set :tcd", 1, true))
      assert(#resession.list({ dir = "worktree-sessions" }) == 2)
      vim.cmd.tabnew()
      local anchor = root .. "/anchor.txt"
      vim.fn.writefile({ "keep this tab" }, anchor)
      vim.cmd.edit(vim.fn.fnameescape(anchor))
      vim.cmd.tcd(vim.fn.fnameescape(root))
      local anchor_tab, anchor_win, anchor_buf = vim.api.nvim_get_current_tabpage(),
        vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
      local function picker()
        vim.cmd.stopinsert()
        vim.cmd.WorktreeSessionLoad()
        local prompt = vim.api.nvim_get_current_buf()
        assert(vim.bo[prompt].filetype == "TelescopePrompt", "must use the profile's vim.ui.select")
        local state = require("telescope.actions.state")
        local picker = state.get_current_picker(prompt)
        wait(function() return picker.manager and picker.manager:num_results() == 2 and picker:get_selection() end)
        local labels = {}
        for entry in picker.manager:iter() do labels[#labels + 1] = entry.ordinal end
        table.sort(labels)
        assert(vim.deep_equal(labels, { a, b }), vim.inspect(labels))
        return picker, prompt
      end
      local function choose(wanted)
        local picker, prompt = picker()
        local actions = require("telescope.actions")
        for _ = 1, 2 do
          if picker:get_selection().value.text.root == wanted then break end
          actions.move_selection_next(prompt)
        end
        assert(picker:get_selection().value.text.root == wanted)
        return prompt
      end
      local actions = require("telescope.actions")
      local before = snapshot()
      local _, prompt = picker()
      actions.close(prompt)
      wait(function() return vim.api.nvim_get_current_win() == anchor_win end)
      unchanged(before)
      -- Valid selections add tab sessions without resetting the existing tabs.
      local original_tabs = vim.api.nvim_list_tabpages()
      local load, load_calls = resession.load, 0
      resession.load = function(name, opts)
        assert(opts.reset == false and opts.attach == false)
        load_calls = load_calls + 1
        return load(name, opts)
      end
      local function select(prompt)
        local count = load_calls + #notices
        actions.select_default(prompt)
        wait(function() return load_calls + #notices > count end)
      end
      for _, wanted in ipairs({ a, b }) do
        vim.api.nvim_set_current_tabpage(anchor_tab)
        select(choose(wanted))
        wait(function() return vim.fn.getcwd(-1, 0) == wanted end)
        for _, tab in ipairs(original_tabs) do assert(vim.api.nvim_tabpage_is_valid(tab)) end
        assert(vim.api.nvim_win_get_buf(anchor_win) == anchor_buf)
        local filenames = {}
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          filenames[#filenames + 1] = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
        end
        assert(vim.tbl_contains(filenames, wanted .. "/second.txt"))
        if wanted == a then
          assert(#filenames == 2 and vim.tbl_contains(filenames, a .. "/first.txt"))
        else
          assert(#filenames == 1)
        end
      end
      assert(load_calls == 2 and #vim.api.nvim_list_tabpages() == #original_tabs + 2)
      -- Removal after opening the real picker must be refused before upstream load.
      vim.api.nvim_set_current_tabpage(anchor_tab)
      before = snapshot()
      prompt = choose(b)
      run({ "git", "worktree", "remove", "--force", b }, repo)
      select(prompt)
      wait(function() return vim.api.nvim_get_current_win() == anchor_win end)
      unchanged(before)
      assert(load_calls == 2 and not resession.is_loading())
      assert(notices[#notices]:find("missing or changed", 1, true))
      -- Also refuse an already-stale entry (even from an empty, reusable tab).
      vim.cmd.tabnew()
      before = snapshot()
      select(choose(b))
      unchanged(before)
      assert(load_calls == 2)
      -- Replacing the root with an ordinary directory or another Git repository is stale.
      vim.fn.mkdir(b, "p")
      before = snapshot()
      select(choose(b))
      unchanged(before)
      assert(load_calls == 2)
      run({ "git", "init", "-q", b })
      before = snapshot()
      select(choose(b))
      unchanged(before)
      assert(load_calls == 2)
      vim.fn.delete(b, "rf")
      run({ "git", "worktree", "add", "-qb", "replacement", b }, repo)
      before = snapshot()
      select(choose(b))
      unchanged(before)
      assert(load_calls == 2, "a recreated worktree must be saved again")
      -- Missing saved window and tab cwd paths are checked before upstream mutates anything.
      local path_a = data_dir .. "/" .. key_a .. ".json"
      local data = read(key_a)
      local original_data = vim.deepcopy(data)
      data.tabs[1].wins = { "leaf", { cwd = a .. "/deleted-window-cwd" } }
      vim.fn.writefile({ vim.json.encode(data) }, path_a)
      before = snapshot()
      select(choose(a))
      unchanged(before)
      assert(load_calls == 2 and notices[#notices]:find("saved cwd is missing", 1, true))
      data = original_data
      data.tabs[1].cwd = a .. "/deleted-subdir"
      vim.fn.writefile({ vim.json.encode(data) }, path_a)
      before = snapshot()
      select(choose(a))
      unchanged(before)
      assert(load_calls == 2 and notices[#notices]:find("saved cwd is missing", 1, true))
      resession.load, vim.notify = load, notify
      vim.cmd.cd(vim.fn.fnameescape(vim.env.HOME))
      vim.fn.delete(root, "rf")
    '';
  };
}
