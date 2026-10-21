-- Isolated synthetic LSP: no user config, language server, or files are modified.
for _, name in ipairs({ 'TINY', 'TELESCOPE', 'PLENARY', 'LSPCONFIG' }) do
  vim.opt.runtimepath:append(assert(vim.env['CODE_ACTION_TEST_' .. name], name))
end
vim.o.columns, vim.o.lines = 120, 40
local notices = {}
vim.notify = function(message, level)
  notices[#notices + 1] = { message = tostring(message), level = level }
end
local function wait(predicate, message)
  assert(vim.wait(5000, predicate, 10), message .. '\n' .. vim.inspect(notices))
end
local function check_notices()
  for _, notice in ipairs(notices) do
    assert(not notice.message:find('Buffer operation failed', 1, true), notice.message)
    assert((notice.level or 0) < vim.log.levels.ERROR, notice.message)
  end
end
local tiny = require('tiny-code-action')
dofile('v2/lua/autogen/tiny-code-action.lua')
assert(tiny.config.backend == 'delta' and tiny.config.picker[1] == 'telescope')
assert(vim.fn.executable('delta') == 1, 'real delta backend required')

if vim.env.CODE_ACTION_TEST_CASE == 'buffer' then
  -- Upstream #120 affects buffer auto-preview, separate from our Telescope picker.
  local preview = require('tiny-code-action.pickers.buffer_utils.preview')
  local previewer = require('tiny-code-action.previewers.buffer')
  previewer.config, previewer.backend = tiny.config, tiny.backend
  local layout = { row = 1, col = 1, width = 35, height = 10, margin = 1,
    win = vim.api.nvim_get_current_win() }
  for _, title in ipairs({ 'First command', 'Second command' }) do
    preview.show_preview({ action = { title = title, command = title } },
      vim.api.nvim_get_current_buf(), previewer, layout, false, tiny.config)
    vim.wait(50, function() return false end)
  end
  check_notices()
  local buf = preview.get_preview_state().buf
  assert(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
    :find('No preview available', 1, true), 'second preview must remain visible')
  preview.close_preview()
  print('buffer preview regression: OK')
  return
end

-- Load a real config through Neovim's current LSP API, without starting its server.
assert(type(vim.lsp.config.lua_ls.cmd) == 'table', 'lspconfig runtime missing')
require('telescope').setup({ defaults = { sorting_strategy = 'ascending' } })
dofile(vim.env.CODE_ACTION_TEST_TELESCOPE .. '/plugin/telescope.lua')
local bufnr = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_name(bufnr, vim.fn.tempname() .. '.lua')
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'local value = 1' })
local uri = vim.uri_from_bufnr(bufnr)
local requests, resolutions, commands = 0, 0, 0
local function edit(text)
  return { changes = { [uri] = { { range = {
    start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 15 },
  }, newText = text } } } }
end
local client_id = assert(vim.lsp.start({
  name = 'code-action-fixture',
  cmd = function(dispatchers)
    local closing, request_id = false, 0
    return {
      request = function(method, params, callback)
        request_id = request_id + 1
        local result
        if method == 'initialize' then
          result = { capabilities = {
            positionEncoding = 'utf-16', codeActionProvider = { resolveProvider = true },
            executeCommandProvider = { commands = { 'fixture.command' } },
          } }
        elseif method == 'textDocument/codeAction' then
          requests = requests + 1
          result = {
            { title = 'Immediate edit', edit = edit('local value = 2') },
            { title = 'Resolved edit', data = { resolve = true } },
            { title = 'Command only', command = { title = 'Run', command = 'fixture.command' } },
          }
        elseif method == 'codeAction/resolve' then
          resolutions = resolutions + 1
          result = vim.deepcopy(params)
          if params.data then result.edit = edit('local value = 3') end
        elseif method == 'workspace/executeCommand' then
          commands = commands + 1
        elseif method ~= 'shutdown' then
          error('unexpected request: ' .. method)
        end
        vim.schedule(function() callback(nil, result) end)
        return true, request_id
      end,
      notify = function() return true end,
      is_closing = function() return closing end,
      terminate = function() closing = true; dispatchers.on_exit(0, 0) end,
    }
  end,
}))
wait(function() return vim.lsp.get_client_by_id(client_id).initialized end, 'LSP initialize')
local actions, state = require('telescope.actions'), require('telescope.actions.state')
local function open(title)
  vim.cmd.stopinsert()
  tiny.code_action()
  local picker, prompt
  wait(function()
    prompt = vim.api.nvim_get_current_buf()
    if vim.bo[prompt].filetype ~= 'TelescopePrompt' then return false end
    picker = state.get_current_picker(prompt)
    return picker and picker.manager and picker.manager:num_results() == 3
  end, 'three code actions must reach Telescope')
  for _ = 1, 3 do
    if picker:get_selection().value.action.title == title then break end
    actions.move_selection_next(prompt)
  end
  assert(picker:get_selection().value.action.title == title, title)
  local expected = ({ ['Immediate edit'] = 'local value = 2',
    ['Resolved edit'] = 'local value = 3', ['Command only'] = 'No preview available' })[title]
  wait(function()
    local entry = picker:get_selection().value
    local preview_buf = picker.previewer.state.termopen_bufnr
    return entry._resolved_action and preview_buf and vim.api.nvim_buf_is_valid(preview_buf)
      and table.concat(vim.api.nvim_buf_get_lines(preview_buf, 0, -1, false), '\n')
        :find(expected, 1, true) ~= nil
  end, 'visible preview for ' .. title)
  return prompt
end
local function apply(title)
  local prompt = open(title)
  local count = resolutions
  actions.select_default(prompt)
  vim.wait(50, function() return false end)
  assert(resolutions == count, 'preview resolution must be reused when applying')
  check_notices()
end
apply('Immediate edit')
assert(vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == 'local value = 2')
apply('Resolved edit')
assert(vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == 'local value = 3')
apply('Command only')
wait(function() return commands == 1 end, 'command must execute once')
assert(requests == 3)
vim.lsp.get_client_by_id(client_id):stop(true)
print('Telescope + delta + LSP: list, switch preview, resolve, edit, command: OK')
