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

local function worktree_sorter(opts)
  local sorter = require('telescope.config').values.generic_sorter(opts)
  local score = sorter.scoring_function
  sorter.scoring_function = function(self, prompt, line, entry, ...)
    local value = score(self, prompt, line, entry, ...)
    -- Keep the configured sorter's filtering, highlighting and lifecycle. Map
    -- matched scores into disjoint bands so fuzzy matches cannot lift stale
    -- registrations above other entries, even with a non-empty prompt.
    if value < 0 then return value end
    local rank = value == math.huge and 1 or value / (1 + value)
    return rank / 4 + (entry.value.status == 'prunable' and 0.5 or 0)
  end
  return sorter
end

function M.pick(opts)
  opts = opts or {}
  local cwd = opts.cwd or vim.fn.getcwd()
  local output, err = run({ 'git', 'gtr', 'list', '--porcelain' }, cwd)
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
    prompt_title = 'gtr worktrees | new: branch name',
    finder = require('telescope.finders').new_table({
      results = entries,
      entry_maker = function(entry)
        return { value = entry, ordinal = entry.branch .. ' ' .. entry.path,
          display = entry.branch .. ' [' .. entry.status .. ']  ' .. entry.path }
      end,
    }),
    sorter = worktree_sorter(opts),
    attach_mappings = function(buf)
      local function select()
        local entry = state.get_selected_entry()
        if not entry then
          local branch = vim.trim(state.get_current_line())
          if branch == '' then actions.close(buf); return end
          local valid, validation_error = run({ 'git', 'check-ref-format', '--branch', branch }, cwd)
          -- Refuse Git's previous-checkout shorthand: the prompt is a literal branch name.
          if not valid or branch:match('^@{') then
            vim.notify('Invalid branch name: ' .. branch .. '\n' .. (validation_error or ''), vim.log.levels.ERROR)
            return
          end
          actions.close(buf)
          vim.notify('Creating worktree: ' .. branch)
          -- Keep Neovim responsive during fetch/hooks. Use argv, never a shell command.
          vim.system({ 'git', 'gtr', 'new', branch, '--yes' }, { cwd = cwd, text = true }, vim.schedule_wrap(function(result)
            if result.code ~= 0 then
              vim.notify('gtr worktree creation failed: ' .. vim.trim((result.stderr or '') .. '\n' .. (result.stdout or '')), vim.log.levels.ERROR)
              return
            end
            local path, resolve_error = run({ 'git', 'gtr', 'go', branch }, cwd)
            path = path and vim.trim(path)
            if not path or vim.fn.isdirectory(path) ~= 1 then
              vim.notify('Worktree created but its path could not be resolved: ' .. (resolve_error or branch), vim.log.levels.ERROR)
              return
            end
            require('telescope.builtin').find_files({ cwd = path })
          end))
          return
        end
        local path = entry.value.path
        if vim.fn.isdirectory(path) ~= 1 then
          vim.notify('Worktree no longer exists: ' .. path, vim.log.levels.ERROR); return
        end
        actions.close(buf)
        require('telescope.builtin').find_files({ cwd = path })
      end
      actions.select_default:replace(select)
      return true
    end,
  }):find()
end

return M
