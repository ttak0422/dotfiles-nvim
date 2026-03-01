-- [nfnl] v2/fnl/avante.fnl
pcall(dofile, (vim.env.HOME .. "/.config/nvim/avante.lua"))
local avante = require("avante")
local lib = require("avante_lib")
lib.load()
local behaviour = {auto_set_highlight_group = true, auto_set_keymaps = true, support_paste_from_clipboard = true, minimize_diff = true, enable_token_counting = true, auto_approve_tool_permissions = true, auto_check_diagnostics = true, confirmation_ui_style = "inline_buttons", acp_follow_agent_locations = false, auto_add_current_file = false, auto_apply_diff_after_generation = false, auto_focus_on_diff_view = false, auto_focus_sidebar = false, auto_suggestions = false, auto_suggestions_respect_ignore = false, enable_fastapply = false, include_generated_by_commit_line = false, jump_result_buffer_on_finish = false, use_cwd_as_project_root = false}
local mappings
do
  local diff = {ours = "co", theirs = "ct", all_theirs = "ca", both = "cb", cursor = "cc", next = "]x", prev = "[x"}
  local suggestion = {accept = "<M-l>", next = "<M-]>", prev = "<M-[>", dismiss = "<M-e>"}
  local jump = {next = "]]", prev = "[["}
  local submit = {normal = "<CR>", insert = "<C-s>"}
  local cancel = {normal = {"<C-c>", "<Esc>", "q"}, insert = {"<C-c>"}}
  local sidebar = {apply_all = "A", apply_cursor = "a", retry_user_request = "r", edit_user_request = "e", switch_windows = "<Tab>", reverse_switch_windows = "<S-Tab>", remove_file = "d", add_file = "@", close = {"q"}, close_from_input = {normal = "q"}}
  mappings = {diff = diff, suggestion = suggestion, jump = jump, submit = submit, cancel = cancel, sidebar = sidebar}
end
local windows = {position = "left", fillchars = "eob: ", wrap = true, width = 30, height = 50, sidebar_header = {align = "center", enabled = false, rounded = false}, spinner = {editing = {"\226\161\128", "\226\160\132", "\226\160\130", "\226\160\129", "\226\160\136", "\226\160\144", "\226\160\160", "\226\162\128", "\226\163\128", "\226\162\132", "\226\162\130", "\226\162\129", "\226\162\136", "\226\162\144", "\226\162\160", "\226\163\160", "\226\162\164", "\226\162\162", "\226\162\161", "\226\162\168", "\226\162\176", "\226\163\176", "\226\162\180", "\226\162\178", "\226\162\177", "\226\162\184", "\226\163\184", "\226\162\188", "\226\162\186", "\226\162\185", "\226\163\185", "\226\162\189", "\226\162\187", "\226\163\187", "\226\162\191", "\226\163\191"}, generating = {{"\226\150\150", "\226\150\152", "\226\150\157", "\226\150\151"}}, thinking = {"\226\150\129", "\226\150\130", "\226\150\131", "\226\150\132", "\226\150\133", "\226\150\134", "\226\150\135", "\226\150\136"}}, input = {prefix = "\239\146\181 ", height = 8}, edit = {border = "single", start_insert = true}, ask = {floating = true, border = "single", start_insert = true, focus_on_apply = "ours"}}
local diff = {autojump = true, override_timeoutlen = 1000}
local repo_map = {ignore_patterns = {"%.git", "%.worktree", "__pycache__", "node_modules", "result"}, negate_patterns = {}}
local selector = {provider = "telescope"}
local hub = require("mcphub")
local hub_ext = require("mcphub.extensions.avante")
hub.setup({extensions = {avante = {make_slash_commands = true}}})
local system_prompt
local function _1_()
  local _2_
  do
    local tmp_3_ = hub.get_hub_instance()
    if (nil ~= tmp_3_) then
      _2_ = tmp_3_:get_active_servers_prompt()
    else
      _2_ = nil
    end
  end
  return (_2_ or "")
end
system_prompt = _1_
local custom_tools
local function _4_()
  return {hub_ext.mcp_tool()}
end
custom_tools = _4_
local acp_providers = {["claude-code"] = {command = "claude-code-acp", args = {}, env = {NODE_NO_WARNINGS = "1", CLAUDE_CODE_OAUTH_TOKEN = os.getenv("CLAUDE_CODE_OAUTH_TOKEN")}}}
local rag_service = {host_mount = os.getenv("HOME"), runner = "nix", llm = {provider = "ollama", endpoint = "http://localhost:11434", api_key = "", model = "gpt-oss:20b", extra = nil}, embed = {provider = "ollama", endpoint = "https://api.openai.com/v1", api_key = "", model = "gpt-oss:20b", extra = nil}, docker_extra_args = "", enabled = false}
local history = {max_tokens = 8192, carried_entry_count = nil, storage_path = (vim.fn.stdpath("state") .. "/avante"), paste = {extension = "png", filename = "pasted-%Y%m%d%H%M%S"}}
local highlights = {diff = {current = "DiffText", incoming = "DiffAdd"}}
local img_paste = {url_encode_path = true, template = "\nimage: $FILE_PATH\n"}
local hints = {enabled = false}
local input = {provider = "snacks", provider_opts = {}}
local slash_commands = {}
avante.setup({provider = "claude-code", mode = "agentic", auto_suggestions_provider = "ollama", behaviour = behaviour, mappings = mappings, rag_service = rag_service, tokenizer = "tiktoken", disabled_tools = {"web_search", "list_files", "search_files", "read_file", "create_file", "rename_file", "delete_file", "create_dir", "rename_dir", "delete_dir", "bash"}, system_prompt = system_prompt, custom_tools = custom_tools, acp_providers = acp_providers, history = history, highlights = highlights, img_paste = img_paste, windows = windows, diff = diff, hints = hints, selector = selector, input = input, repo_map = repo_map, slash_commands = slash_commands})
local blink = require("blink.cmp")
local function _5_()
  return vim.tbl_contains({"AvanteInput"}, vim.bo.filetype)
end
blink.add_source_provider("avante", {module = "blink-cmp-avante", name = "Avante", opts = {}, enabled = _5_})
return blink.add_filetype_source("AvanteInput", "avante")
