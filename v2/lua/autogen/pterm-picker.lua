-- [nfnl] v2/fnl/pterm-picker.fnl
local pterm = require("pterm")
local telescope = require("telescope")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local parser = require("telescope-live-grep-args.prompt_parser")
telescope.load_extension("pterm")
local function create_session(prompt_bufnr)
  local prompt = vim.trim(action_state.get_current_line())
  local names = pterm.list()
  local argv
  if vim.tbl_contains(names, prompt) then
    argv = {prompt}
  else
    argv = parser.parse(prompt, false)
  end
  local name = argv[1]
  local command = argv[2]
  if ((name == nil) or (name == "")) then
    return actions.close(prompt_bufnr)
  elseif (command and vim.tbl_contains(names, name)) then
    return vim.notify(("Session '" .. name .. "' already exists; select it without a command"), vim.log.levels.ERROR)
  elseif (command and (vim.fn.executable(command) == 0)) then
    return vim.notify(("Executable not found: " .. command), vim.log.levels.ERROR)
  else
    actions.close(prompt_bufnr)
    local ok, err = pcall(pterm.open, name, argv)
    if not ok then
      return vim.notify(("Failed to open session '" .. name .. "': " .. tostring(err)), vim.log.levels.ERROR)
    else
      return nil
    end
  end
end
local extension = telescope.extensions.pterm
local sessions = extension.sessions
local configured
local function _4_(opts)
  local opts0 = vim.tbl_extend("force", {}, (opts or {}))
  local attach = opts0.attach_mappings
  opts0.prompt_title = (opts0.prompt_title or "pterm sessions | new: name [command args...]")
  local function _5_(prompt_bufnr, map)
    local function _6_()
      return (action_state.get_selected_entry() == nil)
    end
    local function _7_()
      return create_session(prompt_bufnr)
    end
    actions.select_default:replace_if(_6_, _7_)
    if attach then
      return attach(prompt_bufnr, map)
    else
      return true
    end
  end
  opts0.attach_mappings = _5_
  return sessions(opts0)
end
configured = _4_
extension.sessions = configured
extension.pterm = configured
return nil
