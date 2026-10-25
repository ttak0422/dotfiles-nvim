local hud = require('hud')
local api = vim.api
local ignored_buftypes = { nofile = true, prompt = true, help = true, quickfix = true }
local maven_prefixes = {
  java = { 'src/main/java/', 'src/test/java/' },
  kotlin = { 'src/main/kotlin/', 'src/test/kotlin/' },
  scala = { 'src/main/scala/', 'src/test/scala/' },
}
local git_roots = {}

-- Keep Incline's path formatting, but never walk the filesystem on cursor moves.
local file = {
  update = { 'BufEnter', 'FileType', 'WinResized', 'VimResized', 'OptionSet' },
  provider = function(ctx)
    local name = api.nvim_buf_get_name(ctx.buf)
    local cached = git_roots[ctx.buf]
    if not cached or cached.name ~= name then
      cached = { name = name, root = name ~= '' and vim.fs.root(name, { '.git' }) or false }
      git_roots[ctx.buf] = cached
    end
    local filename = vim.fn.fnamemodify(name, ':t')
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
      { provider = filename ~= '' and filename or '[No Name]', hl = 'Title', priority = 20 },
      { provider = path ~= '' and path ~= '.' and (' ' .. path) or '', hl = 'WinBar', priority = 0 },
    }
  end,
}
local indicator = {
  update = { 'BufModifiedSet' },
  provider = function(ctx)
    return vim.bo[ctx.buf].modified and ' ' or ''
  end,
  hl = 'DiagnosticWarn',
  priority = 10,
}
local ruler = {
  update = { 'CursorMoved', 'CursorMovedI', 'TextChanged', 'TextChangedI', 'TextChangedP', 'WinEnter', 'WinLeave' },
  provider = function(ctx)
    return ('%4d,%-3d'):format(ctx.lnum, ctx.byte_col + 1)
  end,
  hl = 'WinBar',
  priority = 10,
}
local branch = {
  update = { 'User', 'BufEnter' },
  provider = function(ctx)
    local status = vim.b[ctx.buf].gitsigns_status_dict
    if not status or not status.head or status.head == '' then
      return ''
    end
    local dirty = (status.added or 0) + (status.changed or 0) + (status.removed or 0) > 0
    return ' (' .. status.head .. (dirty and '*' or '') .. ')'
  end,
  priority = 0,
}
local diagnostics = {
  update = { 'DiagnosticChanged' },
  provider = function(ctx)
    local counts = vim.diagnostic.count(ctx.buf)
    local result = {}
    for _, item in ipairs({ { 1, '  ', 'DiagnosticError' }, { 2, '  ', 'DiagnosticWarn' } }) do
      local count = counts[item[1]] or 0
      if count > 0 then
        result[#result + 1] = { provider = item[2] .. count, hl = item[3] }
      end
    end
    return #result > 0 and result or nil
  end,
}
local git_diff = {
  update = { 'User', 'BufEnter' },
  provider = function(ctx)
    local status = vim.b[ctx.buf].gitsigns_status_dict or {}
    local result = {}
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
    return #result > 0 and result or nil
  end,
}
local active = { { indicator, file }, { ruler, branch }, diagnostics, git_diff }
local inactive = { active[1], active[2] }
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
