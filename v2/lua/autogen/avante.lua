-- [nfnl] v2/fnl/avante.fnl
local avante = require("avante")
local avante_lib = require("avante_lib")
local hub = require("mcphub")
local hub_ext = require("mcphub.extensions.avante")
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
local behaviour = {auto_set_highlight_group = true, auto_set_keymaps = true, support_paste_from_clipboard = true, minimize_diff = true, enable_token_counting = true, auto_apply_diff_after_generation = false, auto_focus_on_diff_view = false, auto_focus_sidebar = false, auto_suggestions = false, auto_suggestions_respect_ignore = false, jump_result_buffer_on_finish = false, use_cwd_as_project_root = false}
local history = {max_tokens = 8192, carried_entry_count = nil, storage_path = (vim.fn.stdpath("state") .. "/avante"), paste = {extension = "png", filename = "pasted-%Y%m%d%H%M%S"}}
local highlights = {diff = {current = "DiffText", incoming = "DiffAdd"}}
local img_paste = {url_encode_path = true, template = "\nimage: $FILE_PATH\n"}
local mappings = {diff = {ours = "co", theirs = "ct", all_theirs = "ca", both = "cb", cursor = "cc", next = "]x", prev = "[x"}, suggestion = {accept = "<C-a>", next = "<M-]>", prev = "<M-[>", dismiss = "<M-e>"}, jump = {next = "]]", prev = "[["}, submit = {normal = "<CR>", insert = "<C-s>"}, cancel = {normal = {"<C-c>", "<Esc>", "q"}, insert = {"<C-c>"}}, ask = "<leader>aa", new_ask = "<leader>an", edit = "<leader>ae", refresh = "<leader>ar", focus = "<leader>af", stop = "<leader>aS", toggle = {default = "<leader>at", debug = "<leader>ad", hint = "<leader>ah", suggestion = "<leader>as", repomap = "<leader>aR"}, sidebar = {apply_all = "A", apply_cursor = "a", retry_user_request = "r", edit_user_request = "e", switch_windows = "<Tab>", reverse_switch_windows = "<S-Tab>", remove_file = "d", add_file = "@", close = {"q"}, close_from_input = {normal = "q"}}, files = {add_current = "<leader>ab", add_all_buffers = "<leader>aB"}, select_model = "<leader>a?", select_history = "<leader>ah"}
local windows = {position = "right", fillchars = "eob: ", wrap = true, width = 50, height = 50, sidebar_header = {align = "center", enabled = false, rounded = false}, input = {prefix = "\239\146\181 ", height = 8}, edit = {border = {[" "] = " "}, start_insert = true}, ask = {border = {[" "] = " "}, start_insert = true, focus_on_apply = "ours", floating = false}}
local diff = {autojump = true, override_timeoutlen = 1000}
local hints = {enabled = false}
local repo_map = {ignore_patterns = {"%.git", "%.worktree", "__pycache__", "node_modules", "result"}, negate_patterns = {}}
avante_lib.load()
avante.setup({mode = "agentic", provider = "sonet4", providers = {sonet4 = {__inherited_from = "claude", model = "claude-sonnet-4-0"}, opus4 = {__inherited_from = "claude", model = "claude-opus-4-0", extra_request_body = {max_tokens = 32000}}}, tokenizer = "tiktoken", disabled_tools = {"web_search"}, system_prompt = system_prompt, custom_tools = custom_tools, behaviour = behaviour, history = history, highlights = highlights, img_paste = img_paste, mappings = mappings, windows = windows, diff = diff, hints = hints, repo_map = repo_map})
return pcall(dofile, (vim.env.HOME .. "/.config/nvim/avante.lua"))
