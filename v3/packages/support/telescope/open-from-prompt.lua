-- Add an explicit action without changing the picker's default selection.
local M = {}

local function prompt_text(buf)
  local picker = require("telescope.actions.state").get_current_picker(buf)
  local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
  return line:sub(#picker.prompt_prefix + 1)
end

local function with_mapping(pick, open, configure)
  return function(opts)
    opts = vim.tbl_extend("force", {}, opts or {})
    if configure then configure(opts) end
    local attach = opts.attach_mappings
    opts.attach_mappings = function(buf, map)
      for _, mode in ipairs({ "i", "n" }) do
        map(mode, "<C-o>", function()
          local prompt = prompt_text(buf)
          if prompt:find("%S") then open(buf, prompt) end
        end)
      end
      if attach then return attach(buf, map) end
      return true
    end
    return pick(opts)
  end
end

function M.setup(telescope)
  local actions = require("telescope.actions")
  local state = require("telescope.actions.state")
  local pterm = require("pterm")
  local parser = require("telescope-live-grep-args.prompt_parser")
  local function open_session_from_prompt(buf, prompt, close_empty)
    prompt = vim.trim(prompt)
    local names = pterm.list()
    -- Preserve existing names containing spaces instead of parsing them as commands.
    local argv = vim.tbl_contains(names, prompt) and { prompt } or parser.parse(prompt, false)
    local name, command = argv[1], argv[2]
    if not name or name == "" then
      if close_empty then actions.close(buf) end
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
    actions.close(buf)
    local ok, err = pcall(pterm.open, name, argv)
    if not ok then
      vim.notify("Failed to open session '" .. name .. "': " .. tostring(err), vim.log.levels.ERROR)
    end
  end

  local sessions = telescope.extensions.pterm
  local open_sessions = with_mapping(sessions.sessions, open_session_from_prompt, function(opts)
    opts.prompt_title = opts.prompt_title or "pterm sessions | <C-o> new: name [command args...]"
    local attach = opts.attach_mappings
    opts.attach_mappings = function(buf, map)
      actions.select_default:replace_if(function()
        return state.get_selected_entry() == nil
      end, function()
        open_session_from_prompt(buf, prompt_text(buf), true)
      end)
      if attach then return attach(buf, map) end
      return true
    end
  end)
  sessions.sessions = open_sessions
  sessions.pterm = open_sessions

  local worktab_picker = telescope.extensions.worktab
  worktab_picker.worktab = with_mapping(worktab_picker.worktab, function(buf, name)
    actions.close(buf)
    local worktab = require("worktab")
    if not worktab.goto_tab(name) then worktab.tabnew(name) end
  end)
end

function M.setup_track()
  local track = require("track.telescope")
  local function create_note(buf, prompt)
    require("telescope.actions").close(buf)
    require("track.create").create(vim.trim(prompt))
  end
  for _, name in ipairs({ "search_title", "search_body" }) do
    local search = with_mapping(track[name], create_note)
    track[name] = function(opts)
      -- Load the configured picker before the first :Track search, too.
      require("telescope")
      return search(opts)
    end
  end
end

return M
