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
    # hud.nvim

    ## 概要
    複数行の情報表示を部品から組み立てる HUD。

    ## 主な機能
    - 文字列・関数・入れ子の部品で行を構成する。
    - リポジトリ名とブランチ、相対ディレクトリ、ファイル名、診断と Git 差分、ruler の順に最大 5 行で表示する。情報のない行は省略する。
    - ruler は以前の `%4d,%-3d` 形式を使い、カラムの桁数が変わっても 3 桁までは表示幅を保つ。
    - イベント単位の更新キャッシュ、幅不足時の優先度、カーソルとの重なり回避を扱う。

    ## 使い方
    `require("hud").setup({ lines = ... })` で設定する。`hide()` / `show()` は一時表示、`disable()` / `enable()` は更新の停止・再開、`refresh()` は再評価を行う。

    ## 要件
    Neovim 0.10 以上。

    ## 出典
    [固定バージョンの README](https://github.com/ttak0422/hud.nvim/blob/4990a3ac4c73da75d64dba58d19f37ede17e7b6a/README.md)
  '';

  plugin = sources.hud-nvim;
  config = luaConfig (
    # lua
    ''
      local hud = require('hud')
      local api = vim.api
      local ignored_buftypes = { nofile = true, prompt = true, help = true, quickfix = true }
      local maven_prefixes = {
        java = { 'src/main/java/', 'src/test/java/' },
        kotlin = { 'src/main/kotlin/', 'src/test/kotlin/' },
        scala = { 'src/main/scala/', 'src/test/scala/' },
      }
      local git_roots = {}
      local indicator = {
        update = { 'BufModifiedSet' },
        provider = function(ctx)
          return vim.bo[ctx.buf].modified and ' ' or '''
        end,
        hl = 'DiagnosticWarn',
        priority = 10,
      }

      -- Share the cached root across repository/path rows; never walk on cursor moves.
      local function git_root(ctx)
        local name = api.nvim_buf_get_name(ctx.buf)
        local cached = git_roots[ctx.buf]
        if not cached or cached.name ~= name then
          cached = {
            name = name,
            root = name ~= ''' and vim.bo[ctx.buf].buftype == '''
              and not name:match('^%w+://') and vim.fs.root(name, { '.git' }) or false,
          }
          git_roots[ctx.buf] = cached
        end
        return cached.root
      end
      local repository = {
        priority = 20,
        update = { 'BufEnter' },
        provider = function(ctx)
          local root = git_root(ctx)
          return root and (' ' .. vim.fn.fnamemodify(root, ':t')) or '''
        end,
        hl = 'WinBar',
      }
      local location = {
        priority = 20,
        update = { 'BufEnter', 'FileType', 'WinResized', 'VimResized', 'OptionSet' },
        provider = function(ctx)
          local name = api.nvim_buf_get_name(ctx.buf)
          local root = git_root(ctx)
          local relative = root and name:sub(#root + 2) or vim.fn.fnamemodify(name, ':.')
          local path = vim.fn.fnamemodify(relative, ':h')
          for _, prefix in ipairs(maven_prefixes[vim.bo[ctx.buf].filetype] or {}) do
            if vim.startswith(path, prefix) then
              path = path:sub(#prefix + 1)
            end
          end
          if api.nvim_win_get_width(ctx.win) < 100 then
            path = vim.fn.pathshorten(path)
          end
          return { ' ', { provider = path ~= ''' and path or '.', hl = 'WinBar' } }
        end,
      }
      local file = {
        -- Keep the row padding with the filename when lower-priority parts yield.
        priority = 20,
        update = { 'BufEnter' },
        provider = function(ctx)
          local filename = vim.fn.fnamemodify(api.nvim_buf_get_name(ctx.buf), ':t')
          return {
            ' ',
            indicator,
            { provider = filename ~= ''' and filename or '[No Name]', hl = 'Title' },
          }
        end,
      }
      local ruler = {
        update = { 'CursorMoved', 'CursorMovedI', 'TextChanged', 'TextChangedI', 'TextChangedP', 'WinEnter', 'WinLeave' },
        provider = function(ctx)
          return { ' ', { provider = ('%4d,%-3d'):format(ctx.lnum, ctx.byte_col + 1), hl = 'WinBar' } }
        end,
        priority = 10,
      }
      local branch = {
        update = { 'User', 'BufEnter', 'WinEnter', 'WinLeave' },
        provider = function(ctx)
          local status = vim.b[ctx.buf].gitsigns_status_dict
          if not status or not status.head or status.head == ''' then
            return '''
          end
          return '  ' .. status.head
        end,
        priority = 0,
      }
      local diagnostics = {
        update = { 'DiagnosticChanged' },
        provider = function(ctx)
          local counts = vim.diagnostic.count(ctx.buf)
          local result = { ' ' }
          for _, item in ipairs({ { 1, '  ', 'DiagnosticError' }, { 2, '  ', 'DiagnosticWarn' } }) do
            local count = counts[item[1]] or 0
            if count > 0 then
              result[#result + 1] = { provider = item[2] .. count, hl = item[3] }
            end
          end
          return #result > 1 and result or nil
        end,
      }
      local git_diff = {
        update = { 'User', 'BufEnter' },
        provider = function(ctx)
          local status = vim.b[ctx.buf].gitsigns_status_dict or {}
          local result = { ' ' }
          for _, item in ipairs({
            { 'added', '  ', 'HudGitAdded' },
            { 'changed', '  ', 'HudGitChanged' },
            { 'removed', '  ', 'HudGitRemoved' },
          }) do
            local count = status[item[1]] or 0
            if count > 0 then
              result[#result + 1] = { provider = item[2] .. count, hl = item[3] }
            end
          end
          return #result > 1 and result or nil
        end,
      }
      local active = { { repository, branch }, location, file, { diagnostics, git_diff }, ruler }
      local inactive = { active[1], location, file }
      local group = api.nvim_create_augroup('hud-config', { clear = true })
      local function highlights()
        for _, item in ipairs({ { 'Added', 10 }, { 'Changed', 12 }, { 'Removed', 9 } }) do
          api.nvim_set_hl(0, 'HudGit' .. item[1], { fg = vim.g['terminal_color_' .. item[2]], bold = true })
        end
      end
      highlights()
      api.nvim_create_autocmd('ColorScheme', { group = group, callback = highlights })
      -- These events are outside hud.nvim's supported component dependencies.
      api.nvim_create_autocmd({ 'BufFilePost', 'DirChanged', 'BufWipeout' }, {
        group = group,
        callback = function(event)
          if event.event == 'DirChanged' then
            git_roots = {}
          else
            git_roots[event.buf] = nil
          end
          hud.refresh()
        end,
      })
      hud.setup({
        position = { col = 1 },
        hl = 'WinBar',
        inactive_hl = 'WinBarNC',
        filter = function(ctx)
          local ft = vim.bo[ctx.buf].filetype
          return not ignored_buftypes[vim.bo[ctx.buf].buftype]
            and not vim.wo[ctx.win].previewwindow
            and not vim.startswith(ft, 'git')
            and ft ~= 'Trouble'
            and ft ~= 'skk-terminal-input'
        end,
        lines_update = { 'WinEnter', 'WinLeave' },
        lines = function(ctx)
          return ctx.focused and active or inactive
        end,
      })
    ''
  );
  tests.hud-path = luaCheck {
    name = "hud-path";
    ui = true;
    script = ''
      local api, hud = vim.api, require('hud')
      local base, cwd = vim.fn.tempname(), vim.fn.getcwd()
      local repository, plain = base .. '/repository', base .. '/plain'
      local find_root, root_calls = vim.fs.root, 0
      local ns = api.nvim_create_namespace('hud-layout-test')
      -- Keep unrelated ancestor markers outside the test fixture out of non-Git cases.
      vim.fs.root = function(...)
        root_calls = root_calls + 1
        local root = find_root(...)
        return root and vim.startswith(root, base .. '/') and root or nil
      end
      local content = {}
      for line = 1, 50 do content[line] = string.rep('x', 120) end
      local function rows(win)
        for _, candidate in ipairs(api.nvim_list_wins()) do
          local buf = api.nvim_win_get_buf(candidate)
          if vim.b[buf].hud_source_win == (win or api.nvim_get_current_win()) then
            return api.nvim_buf_get_lines(buf, 0, -1, false), candidate
          end
        end
      end
      local function expect(expected, win)
        assert(vim.wait(2000, function()
          local lines, float = rows(win)
          return lines and vim.deep_equal(vim.tbl_map(vim.trim, lines), expected)
            and api.nvim_win_get_config(float).height == #expected
        end, 10), 'HUD rows: ' .. vim.inspect((rows(win))) .. ', expected: ' .. vim.inspect(expected))
      end
      local function header(repository_name, directory, filename, win)
        local expected = repository_name and { repository_name, directory, filename } or { directory, filename }
        assert(vim.wait(2000, function()
          local lines = rows(win)
          if not lines then return false end
          for i, text in ipairs(expected) do
            if vim.trim(lines[i] or ''') ~= text then return false end
          end
          return true
        end, 10), 'HUD header: ' .. vim.inspect((rows(win))))
      end
      local function status(value)
        vim.b.gitsigns_status_dict = value
        api.nvim_exec_autocmds('User', { pattern = 'GitSignsUpdate' })
      end
      local function diagnostics(enabled)
        local items = enabled and {
          { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = 'error' },
          { lnum = 0, col = 0, severity = vim.diagnostic.severity.WARN, message = 'warning' },
        } or {}
        vim.diagnostic.set(ns, 0, items, { virtual_text = false, signs = false, underline = false })
      end
      local function edit(name)
        vim.fn.mkdir(vim.fn.fnamemodify(name, ':h'), 'p')
        vim.fn.writefile(content, name)
        vim.cmd.edit(vim.fn.fnameescape(name))
        vim.bo.filetype = 'text'
        api.nvim_win_set_cursor(0, { 20, 0 })
        api.nvim_exec_autocmds('CursorMoved', {})
      end
      local function resized(width)
        api.nvim_win_set_width(0, width)
        api.nvim_exec_autocmds('WinResized', {})
      end
      local ok, err = xpcall(function()
        assert(#api.nvim_get_autocmds({ group = 'hud-config' }) > 0, 'profile must configure HUD')
        vim.o.winminwidth, vim.o.winwidth = 1, 1
        vim.wo.number, vim.wo.relativenumber, vim.wo.wrap = false, false, false
        vim.wo.signcolumn, vim.wo.foldcolumn, vim.wo.winbar = 'no', '0', '''
        vim.fn.mkdir(repository, 'p')
        local result = vim.system({ '${pkgs.git}/bin/git', '-C', repository, 'init', '--quiet' }, { text = true }):wait()
        assert(result.code == 0, result.stderr)
        edit(repository .. '/src/example/Example.txt')
        header('repository', 'src/example', 'Example.txt')
        api.nvim_buf_set_lines(0, 0, 1, false, { 'changed' })
        api.nvim_exec_autocmds('BufModifiedSet', {})
        header('repository', 'src/example', ' Example.txt')
        vim.bo.modified = false
        api.nvim_exec_autocmds('BufModifiedSet', {})
        status({ head = 'hud-test', added = 2, changed = 3, removed = 4 })
        diagnostics(true)
        expect({ 'repository  hud-test', 'src/example', 'Example.txt', ' 1  1   2  3  4', '20,1' })
        diagnostics(false)
        expect({ 'repository  hud-test', 'src/example', 'Example.txt', ' 2  3  4', '20,1' })
        status({ head = 'hud-next' })
        diagnostics(true)
        expect({ 'repository  hud-next', 'src/example', 'Example.txt', ' 1  1', '20,1' })
        diagnostics(false)
        expect({ 'repository  hud-next', 'src/example', 'Example.txt', '20,1' })
        -- Restore both providers and verify they share one row after repeated updates.
        diagnostics(true)
        status({ head = 'hud-test', changed = 1 })
        expect({ 'repository  hud-test', 'src/example', 'Example.txt', ' 1  1   1', '20,1' })
        local source = api.nvim_get_current_win()
        vim.cmd.vsplit()
        resized(80)
        expect({ 'repository  hud-test', 's/example', 'Example.txt', ' 1  1   1', '20,1' })
        expect({ 'repository  hud-test', 'src/example', 'Example.txt' }, source)
        resized(18)
        header('repository', 's/example', 'Example.txt')
        vim.cmd.only()
        api.nvim_exec_autocmds('WinResized', {})
        diagnostics(false)
        status({})
        api.nvim_buf_set_name(0, repository .. '/Renamed.txt')
        api.nvim_exec_autocmds('BufFilePost', {})
        expect({ 'repository', '.', 'Renamed.txt', '20,1' })
        edit(repository .. '/src/main/java/org/example/Example.java')
        vim.bo.filetype = 'java'
        header('repository', 'org/example', 'Example.java')

        vim.fn.mkdir(plain, 'p')
        vim.cmd.cd(vim.fn.fnameescape(plain))
        edit(plain .. '/notes/Notes.txt')
        expect({ 'notes', 'Notes.txt', '20,1' })
        vim.cmd.cd(vim.fn.fnameescape(plain .. '/notes'))
        header(nil, '.', 'Notes.txt')
        vim.cmd.cd(vim.fn.fnameescape(repository))
        header(nil, plain .. '/notes', 'Notes.txt')
        vim.cmd.cd(vim.fn.fnameescape(plain))
        local directory = 'directory-that-does-not-fit'
        edit(plain .. '/' .. directory .. '/Clipped.txt')
        header(nil, directory, 'Clipped.txt')
        vim.cmd.vsplit()
        resized(18)
        assert(vim.wait(2000, function()
          local lines = rows()
          local path = lines and vim.trim(lines[1]) or '''
          return path ~= ''' and #path < #directory and vim.startswith(directory, path)
            and vim.trim(lines[2] or ''') == 'Clipped.txt'
        end, 10), 'non-Git directory must clip instead of disappearing')
        vim.cmd.only()
        api.nvim_exec_autocmds('WinResized', {})

        -- Let the ruler determine the width, then cross 1/2/3-digit column boundaries.
        edit(plain .. '/x')
        expect({ '.', 'x', '20,1' })
        local _, float = rows()
        local before = api.nvim_win_get_config(float)
        local scans = root_calls
        for _, column in ipairs({ 9, 10, 99, 100, 10, 1 }) do
          api.nvim_win_set_cursor(0, { 20, column - 1 })
          api.nvim_exec_autocmds('CursorMoved', {})
          local formatted = ('%4d,%-3d'):format(20, column)
          expect({ '.', 'x', vim.trim(formatted) })
          local lines, current = rows()
          local after = api.nvim_win_get_config(current)
          assert(lines[#lines] == ' ' .. formatted, 'ruler lost fixed-width padding')
          assert(after.width == before.width and after.col == before.col, 'column movement shifted HUD')
        end
        assert(root_calls == scans, 'cursor movement must not repeat Git root discovery')
        vim.cmd.enew()
        api.nvim_buf_set_lines(0, 0, -1, false, content)
        vim.bo.modified = false
        api.nvim_win_set_cursor(0, { 20, 0 })
        api.nvim_exec_autocmds('CursorMoved', {})
        expect({ '.', '[No Name]', '20,1' })
      end, debug.traceback)
      hud.disable()
      vim.diagnostic.reset(ns)
      vim.fs.root = find_root
      vim.cmd.cd(vim.fn.fnameescape(cwd))
      vim.fn.delete(base, 'rf')
      assert(ok, err)
    '';
  };
}
