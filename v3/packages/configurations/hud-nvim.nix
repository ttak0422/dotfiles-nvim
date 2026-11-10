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
    - 1 行目にリポジトリ名と相対ディレクトリ、2 行目にファイル名を表示する。Git 管理外ではリポジトリ名を表示しない。
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

      -- Keep Incline's path formatting, but never walk the filesystem on cursor moves.
      local location = {
        priority = 20,
        update = { 'BufEnter', 'FileType', 'WinResized', 'VimResized', 'OptionSet' },
        provider = function(ctx)
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
          local repository = cached.root and vim.fn.fnamemodify(cached.root, ':t') or '''
          local relative = cached.root and name:sub(#cached.root + 2) or vim.fn.fnamemodify(name, ':.')
          local path = vim.fn.fnamemodify(relative, ':h')
          for _, prefix in ipairs(maven_prefixes[vim.bo[ctx.buf].filetype] or {}) do
            if vim.startswith(path, prefix) then
              path = path:sub(#prefix + 1)
            end
          end
          if api.nvim_win_get_width(ctx.win) < 100 then
            path = vim.fn.pathshorten(path)
          end
          return {
            ' ',
            { provider = repository, hl = 'WinBar' },
            {
              provider = (repository ~= ''' and ' ' or ''') .. (path ~= ''' and path or '.'),
              hl = 'WinBar',
              priority = repository ~= ''' and 0 or nil,
            },
          }
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
          return { ' ', { provider = (' %d, %d'):format(ctx.lnum, ctx.byte_col + 1), hl = 'WinBar' } }
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
      local active = { location, file, { git_diff, branch }, ruler, diagnostics }
      local inactive = { location, file, branch }
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
      local find_root = vim.fs.root
      -- Keep unrelated ancestor markers outside the test fixture out of non-Git cases.
      vim.fs.root = function(...)
        local root = find_root(...)
        return root and vim.startswith(root, base .. '/') and root or nil
      end
      local content = {}
      for line = 1, 50 do content[line] = 'source line ' .. line end
      local function rows(win)
        for _, candidate in ipairs(api.nvim_list_wins()) do
          local buf = api.nvim_win_get_buf(candidate)
          if vim.b[buf].hud_source_win == (win or api.nvim_get_current_win()) then
            return api.nvim_buf_get_lines(buf, 0, -1, false)
          end
        end
      end
      local function header(location, filename, win)
        assert(vim.wait(2000, function()
          local lines = rows(win)
          return lines and vim.trim(lines[1]) == location and vim.trim(lines[2] or ''') == filename
        end, 10), 'HUD header: ' .. vim.inspect(rows(win)))
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
        header('repository src/example', 'Example.txt')
        api.nvim_buf_set_lines(0, 0, 1, false, { 'changed' })
        api.nvim_exec_autocmds('BufModifiedSet', {})
        header('repository src/example', ' Example.txt')
        vim.bo.modified = false
        api.nvim_exec_autocmds('BufModifiedSet', {})
        local source = api.nvim_get_current_win()
        vim.cmd.vsplit()
        resized(80)
        header('repository s/example', 'Example.txt')
        header('repository src/example', 'Example.txt', source)
        resized(18)
        header('repository', 'Example.txt')
        vim.cmd.only()
        api.nvim_exec_autocmds('WinResized', {})
        api.nvim_buf_set_name(0, repository .. '/Renamed.txt')
        api.nvim_exec_autocmds('BufFilePost', {})
        header('repository .', 'Renamed.txt')

        vim.fn.mkdir(plain, 'p')
        vim.cmd.cd(vim.fn.fnameescape(plain))
        edit(plain .. '/notes/Notes.txt')
        header('notes', 'Notes.txt')
        vim.cmd.cd(vim.fn.fnameescape(plain .. '/notes'))
        header('.', 'Notes.txt')
        vim.cmd.cd(vim.fn.fnameescape(repository))
        header(plain .. '/notes', 'Notes.txt')
        vim.cmd.cd(vim.fn.fnameescape(plain))
        local directory = 'directory-that-does-not-fit'
        edit(plain .. '/' .. directory .. '/Clipped.txt')
        header(directory, 'Clipped.txt')
        vim.cmd.vsplit()
        resized(18)
        assert(vim.wait(2000, function()
          local lines = rows()
          local path = lines and vim.trim(lines[1]) or '''
          return path ~= ''' and #path < #directory and vim.startswith(directory, path)
            and vim.trim(lines[2] or ''') == 'Clipped.txt'
        end, 10), 'non-Git directory must clip instead of disappearing')
        vim.cmd.only()
        vim.cmd.enew()
        api.nvim_buf_set_lines(0, 0, -1, false, content)
        vim.bo.modified = false
        api.nvim_win_set_cursor(0, { 20, 0 })
        api.nvim_exec_autocmds('CursorMoved', {})
        header('.', '[No Name]')
      end, debug.traceback)
      hud.disable()
      vim.fs.root = find_root
      vim.cmd.cd(vim.fn.fnameescape(cwd))
      vim.fn.delete(base, 'rf')
      assert(ok, err)
    '';
  };
}
