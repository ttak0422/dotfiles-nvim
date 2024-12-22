-- [nfnl] Compiled from fnl/copilot-chat.fnl by https://github.com/Olical/nfnl, do not edit.
local P = require("CopilotChat.prompts")
local S = require("CopilotChat.select")
local namespace = vim.api.nvim_create_namespace("copilot_review")
local selection
local function _1_(src)
  return (S.visual(src) or S.line(src))
end
selection = _1_
local prompts
local function _2_(res, src)
  local bufnr = src.bufnr
  local diagnostics
  do
    local tbl_21_auto = {}
    local i_22_auto = 0
    for line in res:gmatch("[^\13\n]+") do
      local val_23_auto
      if line:find("^line=") then
        local single, msg = line:match("^line=(%d+): (.*)$")
        local t
        if single then
          t = {start = tonumber(single), ["end"] = tonumber(single), message = msg}
        else
          local start, _end, msg0 = line:match("^line=(%d+)-(%d+): (.*)$")
          t = {start = tonumber(start), ["end"] = tonumber(_end), message = msg0}
        end
        if (t.start and t["end"]) then
          val_23_auto = {lnum = (t.start - 1), end_lnum = (t["end"] - 1), col = 0, message = t.message, severity = vim.diagnostic.severity.WARN, source = "Copilot Review"}
        else
          val_23_auto = nil
        end
      else
        val_23_auto = nil
      end
      if (nil ~= val_23_auto) then
        i_22_auto = (i_22_auto + 1)
        tbl_21_auto[i_22_auto] = val_23_auto
      else
      end
    end
    diagnostics = tbl_21_auto
  end
  return vim.diagnostic.set(namespace, bufnr, diagnostics)
end
local function _7_(src)
  return S.gitdiff(src, true)
end
prompts = {Explain = {prompt = "/COPILOT_EXPLAIN \233\129\184\230\138\158\227\129\149\227\130\140\227\129\159\227\130\179\227\131\188\227\131\137\227\130\146\232\167\163\232\170\172\227\129\151\227\129\166\227\129\143\227\129\160\227\129\149\227\129\132."}, Review = {prompt = "/COPILOT_REVIEW \233\129\184\230\138\158\227\129\149\227\130\140\227\129\159\227\130\179\227\131\188\227\131\137\227\129\174\227\131\172\227\131\147\227\131\165\227\131\188\227\130\146\227\129\151\227\129\166\227\129\143\227\129\160\227\129\149\227\129\132.", callback = _2_}, Fix = {prompt = "/COPILOT_GENERATE \227\130\179\227\131\188\227\131\137\228\184\173\227\129\171\227\131\144\227\130\176\227\129\140\229\144\171\227\129\190\227\130\140\227\129\166\227\129\132\227\129\190\227\129\153.\228\184\141\229\133\183\229\144\136\227\130\146\228\191\174\230\173\163\227\129\151\227\129\159\227\130\179\227\131\188\227\131\137\227\130\146\230\143\144\231\164\186\227\129\151\227\129\166\227\129\143\227\129\160\227\129\149\227\129\132."}, Optimize = {prompt = "/COPILOT_GENERATE \233\129\184\230\138\158\227\129\151\227\129\159\227\130\179\227\131\188\227\131\137\227\129\174\227\131\145\227\131\149\227\130\169\227\131\188\227\131\158\227\131\179\227\130\185\227\129\168\229\143\175\232\170\173\230\128\167\227\130\146\229\144\145\228\184\138\227\129\149\227\129\155\227\129\166\227\129\143\227\129\160\227\129\149\227\129\132."}, Docs = {prompt = "/COPILOT_GENERATE \233\129\184\230\138\158\227\129\151\227\129\159\227\130\179\227\131\188\227\131\137\227\129\174DocComment\227\130\146\230\149\180\229\130\153\227\129\151\227\129\166\227\129\143\227\129\160\227\129\149\227\129\132."}, Tests = {prompt = "/COPILOT_GENERATE \233\129\184\230\138\158\227\129\151\227\129\159\227\130\179\227\131\188\227\131\137\227\129\174\227\131\134\227\130\185\227\131\136\227\130\179\227\131\188\227\131\137\227\130\146\231\148\159\230\136\144\227\129\151\227\129\166\227\129\143\227\129\160\227\129\149\227\129\132."}, FixDiagnostic = {prompt = "\227\131\149\227\130\161\227\130\164\227\131\171\228\184\173\227\129\174diagnostics\227\129\171\229\175\190\229\191\156\227\129\153\227\130\139\227\130\179\227\131\188\227\131\137\227\130\146\230\143\144\231\164\186\227\129\151\227\129\166\227\129\143\227\129\160\227\129\149\227\129\132.", selection = S.diagnostics}, Commit = {prompt = "\227\130\179\227\131\159\227\131\131\227\131\136\227\131\161\227\131\131\227\130\187\227\131\188\227\130\184\227\130\146\232\166\143\231\180\132\227\129\171\230\178\191\227\129\163\227\129\166\232\168\152\232\191\176\227\129\151\227\129\166\227\129\143\227\129\160\227\129\149\227\129\132. (\227\130\191\227\130\164\227\131\136\227\131\171\227\129\17550\230\150\135\229\173\151\228\187\165\229\134\133,\227\131\161\227\131\131\227\130\187\227\131\188\227\130\184\227\129\17572\230\150\135\229\173\151\227\129\167\230\148\185\232\161\140\227\129\153\227\130\139)", selection = S.gitdiff}, CommitStaged = {prompt = "\227\130\179\227\131\159\227\131\131\227\131\136\227\131\161\227\131\131\227\130\187\227\131\188\227\130\184\227\130\146\232\166\143\231\180\132\227\129\171\230\178\191\227\129\163\227\129\166\232\168\152\232\191\176\227\129\151\227\129\166\227\129\143\227\129\160\227\129\149\227\129\132. (\227\130\191\227\130\164\227\131\136\227\131\171\227\129\17550\230\150\135\229\173\151\228\187\165\229\134\133,\227\131\161\227\131\131\227\130\187\227\131\188\227\130\184\227\129\17572\230\150\135\229\173\151\227\129\167\230\148\185\232\161\140\227\129\153\227\130\139)", selection = _7_}}
local window = {layout = "float", width = 0.5, height = 0.5, relative = "editor", border = "none", row = nil, col = nil, title = "Copilot Chat", footer = nil, zindex = 1}
local mappings = {complete = {insert = "<Tab>"}, close = {normal = "q", insert = "<C-c>"}, reset = {normal = "<C-l>", insert = "<C-l>"}, submit_prompt = {normal = "<CR>", insert = "<C-s>"}, accept_diff = {normal = "<C-y>", insert = "<C-y>"}, yank_diff = {normal = "gy", register = "\""}, show_diff = {normal = "gd"}, show_system_prompt = {normal = "gp"}, show_info = {normal = "gu"}, show_help = {normal = "g?"}}
local opts = {proxy = nil, system_prompt = P.COPILOT_INSTRUCTIONS, model = "gpt-4o", temperature = 0.1, question_header = "\239\128\135 User ", answer_header = "\239\132\147 Copilot ", error_header = "\239\129\177 Error ", separator = "\226\148\128\226\148\128\226\148\128", show_help = true, auto_follow_cursor = true, highlight_selection = true, context = nil, callback = nil, selection = selection, prompts = prompts, window = window, mappings = mappings, allow_insecure = false, auto_insert_mode = false, clear_chat_on_new_prompt = false, debug = false, insert_at_end = false, show_folds = false}
return require("CopilotChat").setup(opts)
