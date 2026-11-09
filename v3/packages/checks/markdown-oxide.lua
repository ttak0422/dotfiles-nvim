assert(vim.fn.executable("markdown-oxide") == 1, "markdown-oxide is missing from the profile")
assert(vim.lsp.is_enabled("markdown_oxide"), "markdown_oxide must be enabled")
assert(not vim.lsp.is_enabled("marksman"), "Marksman must not run alongside markdown-oxide")
local config = vim.lsp.config.markdown_oxide
assert(vim.deep_equal(config.cmd, { "markdown-oxide" }), vim.inspect(config.cmd))
assert(vim.deep_equal(config.filetypes, { "markdown" }), vim.inspect(config.filetypes))
assert(
  vim.deep_equal(config.root_markers, { ".git", ".obsidian", ".moxide.toml" }),
  "the upstream root markers must be preserved"
)
assert(
  config.capabilities.workspace.didChangeWatchedFiles.dynamicRegistration,
  "markdown-oxide requires dynamic file-watcher registration"
)
assert(
  config.capabilities.textDocument.completion.completionItem.snippetSupport,
  "nvim-cmp completion capabilities must be advertised"
)

local cmp = require("cmp")
local source = vim.iter(cmp.get_config().sources):find(function(item)
  return item.name == "nvim_lsp"
end)
local pattern = assert(source.option.markdown_oxide.keyword_pattern)
assert(
  vim.fn.matchstr("[[notes/Target Note#Heading", pattern .. "$", 0) == "notes/Target Note#Heading",
  "Markdown completion queries must preserve spaces, paths and heading fragments"
)

local root = vim.fn.tempname()
vim.fn.mkdir(root .. "/.obsidian", "p")
vim.fn.mkdir(root .. "/notes", "p")
root = assert(vim.uv.fs_realpath(root))
local target = root .. "/notes/Target Note.md"
local note = root .. "/index.md"
vim.fn.writefile({ "# Target Note", "", "## Heading", "", "A block. ^blockid" }, target)
vim.fn.writefile({
  "# Index",
  "",
  "[[notes/Target Note]]",
  "[[notes/Target Note#Heading]]",
  "[[notes/Target Note#^blockid]]",
  "[target](notes/Target%20Note.md)",
  "",
  "[[Target",
}, note)
vim.cmd.edit(vim.fn.fnameescape(note))
local buf = vim.api.nvim_get_current_buf()
assert(vim.bo[buf].filetype == "markdown")
local client
assert(
  vim.wait(15000, function()
    client = vim.lsp.get_clients({ name = "markdown_oxide", bufnr = buf })[1]
    return client and client.initialized
  end, 50),
  "markdown-oxide did not initialize and attach"
)
assert(
  vim.fs.normalize(client.root_dir) == vim.fs.normalize(vim.uv.fs_realpath(root)),
  "the .obsidian vault must be used as the LSP root: " .. tostring(client.root_dir)
)
assert(#vim.lsp.get_clients({ name = "marksman", bufnr = buf }) == 0)
assert(vim.b[buf].lsp_attached, "the shared LSP mappings must be attached")
assert(vim.fn.exists(":LspToday") == 2, "the upstream daily-note commands must be preserved")

local uri = vim.uri_from_fname(note)
local function request(method, params)
  local response, err = client:request_sync(method, params, 10000, buf)
  assert(response, method .. " timed out: " .. vim.inspect(err))
  assert(not response.err, method .. ": " .. vim.inspect(response.err))
  return response.result
end
local function position(line, character)
  return { textDocument = { uri = uri }, position = { line = line, character = character } }
end
local function is_target(location)
  return vim.uv.fs_realpath(vim.uri_to_fname(location.uri or location.targetUri)) == vim.uv.fs_realpath(target)
end
-- The server initializes before its first workspace scan has finished.
assert(
  vim.wait(10000, function()
    local locations = request("textDocument/definition", position(2, 10))
    return locations and #locations > 0
  end, 100),
  "markdown-oxide did not index the vault"
)

for _, case in ipairs({
  { line = 2, character = 10, target_line = 0 },
  { line = 3, character = 24, target_line = 2 },
  { line = 4, character = 25, target_line = 4 },
  { line = 5, character = 15, target_line = 0 },
}) do
  local locations = request("textDocument/definition", position(case.line, case.character))
  assert(
    locations and #locations == 1 and is_target(locations[1]),
    "link at line " .. case.line .. " did not resolve to the target note: " .. vim.inspect(locations)
  )
  local range = locations[1].range or locations[1].targetSelectionRange
  assert(range.start.line == case.target_line, "link resolved to the wrong line: " .. vim.inspect(locations))
end
local completion = request("textDocument/completion", position(7, 8))
local items = completion.items or completion
assert(
  vim.iter(items):any(function(item)
    return item.label:find("Target Note", 1, true)
  end),
  "wiki-link completion did not include the target note: " .. vim.inspect(items)
)
local refs = request("textDocument/references", {
  textDocument = { uri = vim.uri_from_fname(target) },
  position = { line = 1, character = 0 },
  context = { includeDeclaration = false },
})
assert(refs and vim.iter(refs):any(function(ref)
  return vim.uv.fs_realpath(vim.uri_to_fname(ref.uri)) == vim.uv.fs_realpath(note)
end), "backlinks did not include the referring note: " .. vim.inspect(refs))

-- A real filesystem notification, not a synthetic didChangeWatchedFiles request.
local added = root .. "/notes/Target Later.md"
vim.fn.writefile({ "# Target Later" }, added)
assert(
  vim.wait(10000, function()
    local result = request("textDocument/completion", position(7, 8))
    return vim.iter(result.items or result):any(function(item)
      return item.label:find("Target Later", 1, true)
    end)
  end, 100),
  "new notes were not indexed through the registered file watcher"
)

-- Verify that cmp-nvim-lsp registered the real client and uses its scoped query pattern.
vim.api.nvim_exec_autocmds("InsertEnter", { buffer = buf })
local live_source = vim.iter(cmp.get_registered_sources()):find(function(item)
  return item.name == "nvim_lsp" and item.source.client.id == client.id
end)
assert(live_source, "nvim-cmp did not register the Markdown language server")
assert(
  live_source.source:get_keyword_pattern({ option = source.option }) == pattern,
  "cmp-nvim-lsp did not use the markdown-oxide keyword pattern"
)

local query = "[[Target Note#He"
vim.api.nvim_buf_set_lines(buf, 7, 8, false, { query })
vim.api.nvim_win_set_cursor(0, { 8, #query })
local heading_completion
live_source.source:complete({ completion_context = { triggerKind = 1 }, option = source.option }, function(result)
  heading_completion = result
end)
assert(
  vim.wait(10000, function()
    return heading_completion ~= nil
  end, 50),
  "cmp-nvim-lsp did not return Markdown completions"
)
assert(
  vim.iter(heading_completion.items or heading_completion):any(function(item)
    return item.label == "Target Note#Heading"
  end),
  "cmp-nvim-lsp did not complete a heading after a note name containing a space"
)

client:stop(true)
assert(vim.v.errmsg == "", vim.v.errmsg)
