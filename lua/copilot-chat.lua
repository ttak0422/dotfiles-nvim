local copilot = require("CopilotChat")
local select = require("CopilotChat.select")
copilot.setup({
  system_prompt = "COPILOT_INSTRUCTIONS",

  -- use default
  -- model = 'gpt-4o',
  agent = "copilot",
  context = nil,
  sticky = nil,
  temperature = 0.1,
  headless = false,
  callback = nil,
  remember_as_sticky = true,

  selection = function(source)
    return select.visual(source) or select.buffer(source)
  end,

  window = {
    layout = "float",
    width = 0.75,
    height = 0.75,
    relative = "editor",
    border = "none",
    row = nil,
    col = nil,
    title = "Copilot Chat",
    footer = nil,
    zindex = 1,
  },

  show_help = true,
  highlight_selection = true,
  highlight_headers = true,
  references_display = "virtual",
  auto_follow_cursor = true,
  auto_insert_mode = false,
  insert_at_end = false,
  clear_chat_on_new_prompt = false,

  debug = false,
  log_level = "error",
  proxy = nil,
  allow_insecure = false,
  chat_autocomplete = true,

  log_path = vim.fn.stdpath("state") .. "/CopilotChat.log",
  history_path = vim.fn.stdpath("data") .. "/copilotchat_history",

  question_header = "# User ",
  answer_header = "# Copilot ",
  error_header = "# Error ",
  separator = "───",

  providers = {
    copilot = {},
    github_models = {},
    copilot_embeddings = {},
  },

  contexts = {
    buffer = {},
    buffers = {},
    file = {},
    files = {},
    git = {},
    url = {},
    register = {},
    quickfix = {},
    system = {},
  },

  prompts = {
    Explain = {
      prompt = "選択したコードの説明を段落形式で書いてください。",
      system_prompt = "COPILOT_EXPLAIN",
    },
    Review = {
      prompt = "選択したコードをレビューしてください。",
      system_prompt = "COPILOT_REVIEW",
    },
    Fix = {
      prompt = "このコードには問題があります。問題を特定し、修正を加えてコードを書き直してください。何が問題だったのか、そしてあなたの変更がどのようにその問題を解決するのかを説明してください。",
    },
    Optimize = {
      prompt =
      "選択したコードを最適化して、パフォーマンスと可読性を向上させてください。最適化の戦略と変更の利点を説明してください。"
    },
    Docs = {
      prompt = "選択したコードにドキュメントコメントを追加してください。",
    },
    Tests = {
      prompt = "私のコードのテストを生成してください。",
    },
    Commit = {
      prompt =
      "変更のコミットメッセージを書いてください。コミットメッセージのタイトルは50文字以内にし、メッセージは72文字で折り返してください。メッセージはgitcommitコードブロックとしてフォーマットしてください。",
      context = "git:staged",
    },
  },

  mappings = {
    complete = {
      insert = "<Tab>",
    },
    close = {
      normal = "q",
      insert = "<C-c>",
    },
    reset = {
      normal = "<C-l>",
      insert = "<C-l>",
    },
    submit_prompt = {
      normal = "<CR>",
      insert = "<C-s>",
    },
    toggle_sticky = {
      normal = "grr",
    },
    clear_stickies = {
      normal = "grx",
    },
    accept_diff = {
      normal = "<C-y>",
      insert = "<C-y>",
    },
    jump_to_diff = {
      normal = "gj",
    },
    quickfix_answers = {
      normal = "gqa",
    },
    quickfix_diffs = {
      normal = "gqd",
    },
    yank_diff = {
      normal = "gy",
      register = '"',
    },
    show_diff = {
      normal = "gd",
      full_diff = false,
    },
    show_info = {
      normal = "gi",
    },
    show_context = {
      normal = "gc",
    },
    show_help = {
      normal = "g?",
    },
  },
})

local toggler = require("toggler")
toggler.register("copilot-chat", {
  open = function()
    copilot.open()
  end,
  close = function()
    copilot.close()
  end,
  is_open = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype") == "copilot-chat" then
        return true
      end
    end
    return false
  end,
})
vim.api.nvim_create_user_command("TCopilotChatToggle", function()
  toggler.toggle("copilot-chat")
end, {})
