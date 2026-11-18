local M = {}

local function run(argv, cwd)
  local result = vim.system(argv, { cwd = cwd, text = true }):wait(2000)
  if result.code == 0 then return result.stdout end
  return nil, vim.trim(result.stderr or '')
end

local function absolute(path)
  path = vim.fs.normalize(vim.fn.fnamemodify(path, ':p'), { expand_env = false }):gsub('/+$', '')
  if path == '' then path = '/' end
  return vim.uv.fs_realpath(path) or path
end

local function within(path, root)
  return root == '/' or path == root or path:sub(1, #root + 1) == root .. '/'
end

-- Use registered roots rather than folder-name guesses. This also handles
-- custom gtr locations without hiding unrelated directories named *-worktrees.
function M.roots(cwd)
  if cwd == '~' then cwd = vim.env.HOME
  elseif cwd:sub(1, 2) == '~/' then cwd = vim.env.HOME .. cwd:sub(2) end
  cwd = absolute(cwd)
  local repositories, seen, roots = { cwd }, {}, {}
  local current = run({ 'git', 'worktree', 'list', '--porcelain', '-z' }, cwd)
  local ghq = not current and vim.fn.executable('ghq') == 1
    and run({ 'ghq', 'list', '--full-path' }) or ''
  for repo in (ghq or ''):gmatch('[^\n]+') do
    if within(absolute(repo), cwd) then repositories[#repositories + 1] = repo end
  end
  for _, repo in ipairs(repositories) do
    local output = repo == cwd and current or run({ 'git', 'worktree', 'list', '--porcelain', '-z' }, repo)
    local first = true
    for field in (output or ''):gmatch('[^%z]+') do
      local path = field:match('^worktree (.*)$')
      if path then
        path = absolute(path)
        if not first and not seen[path] and within(path, cwd) and not within(cwd, path) then
          seen[path] = true
          roots[#roots + 1] = path
        end
        first = false
      end
    end
  end
  return roots, cwd
end

local function glob_literal(path)
  return (path:gsub('([\\*?%[%]{}])', '\\%1'))
end

function M.grep_args(opts)
  local args = { '--hidden', '--glob', '!.git' }
  local roots, cwd = M.roots((opts or {}).cwd or vim.fn.getcwd())
  for _, root in ipairs(roots) do
    args[#args + 1] = '--glob'
    args[#args + 1] = '!/' .. glob_literal(root:sub(cwd == '/' and 2 or #cwd + 2)) .. '/**'
  end
  return args
end

function M.find_command(opts)
  local args = { 'rg', '--files' }
  vim.list_extend(args, M.grep_args(opts))
  return args
end

function M.parse(output)
  local entries = {}
  for line in output:gmatch('[^\n]+') do
    local path, branch, status = line:match('^([^\t]+)\t([^\t]+)\t([^\t]*)$')
    if not path or path:sub(1, 1) ~= '/' then
      return nil, 'Unsupported gtr list output (paths containing tabs/newlines are not supported)'
    end
    entries[#entries + 1] = { path = path, branch = branch, status = status }
  end
  return entries
end

function M.pick(opts)
  opts = opts or {}
  local output, err = run({ 'git', 'gtr', 'list', '--porcelain' }, opts.cwd or vim.fn.getcwd())
  if not output then
    vim.notify('gtr worktrees: ' .. (err or 'git gtr is unavailable'), vim.log.levels.ERROR)
    return
  end
  local entries
  entries, err = M.parse(output)
  if not entries then vim.notify(err, vim.log.levels.ERROR); return end
  local actions = require('telescope.actions')
  local state = require('telescope.actions.state')
  require('telescope.pickers').new(opts, {
    prompt_title = 'gtr worktrees | Enter: files · Ctrl-g: grep',
    finder = require('telescope.finders').new_table({
      results = entries,
      entry_maker = function(entry)
        return { value = entry, ordinal = entry.branch .. ' ' .. entry.path,
          display = entry.branch .. ' [' .. entry.status .. ']  ' .. entry.path }
      end,
    }),
    sorter = require('telescope.config').values.generic_sorter(opts),
    attach_mappings = function(buf, map)
      local function select(kind)
        local entry = state.get_selected_entry()
        if not entry then return end
        local path = entry.value.path
        if vim.fn.isdirectory(path) ~= 1 then
          vim.notify('Worktree no longer exists: ' .. path, vim.log.levels.ERROR); return
        end
        actions.close(buf)
        if kind == 'grep' then
          require('telescope').extensions.live_grep_args.live_grep_args({ cwd = path })
        else require('telescope.builtin').find_files({ cwd = path }) end
      end
      actions.select_default:replace(function() select('files') end)
      for _, mode in ipairs({ 'i', 'n' }) do
        map(mode, '<C-g>', function() select('grep') end)
      end
      return true
    end,
  }):find()
end

return M
