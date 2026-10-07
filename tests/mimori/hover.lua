-- Exercise the real Komado row dispatcher with deterministic, deliberately late
-- detail replies. No collector, provider data, or external process is required.
local root = assert(vim.env.MIMORI_TEST_ROOT)
package.path = vim.env.MIMORI_KOMADO .. '/lua/?.lua;' .. vim.env.MIMORI_KOMADO .. '/lua/?/init.lua;'
  .. root .. '/v2/lua/?.lua;' .. package.path
vim.o.columns = 120; vim.o.lines = 40

local current, subscribers, requests = { status = 'loading' }, {}, {}
local client = {}
function client.identity(row) return row.provider .. '\0' .. row.session_id end
function client.snapshot() return current end
function client.subscribe(callback)
  local token = {}; subscribers[token] = callback; callback(current)
  return function() subscribers[token] = nil end
end
function client.refresh() end
function client.detail(provider, id, callback)
  local request = { provider = provider, id = id, callback = callback, cancelled = false }
  requests[#requests + 1] = request
  return function() request.cancelled = true end
end
package.loaded['mimori.client'] = client
local a, k = require('mimori.komado'), require('komado')
local global_hits = 0
vim.keymap.set('n', 'K', function() global_hits = global_hits + 1 end)
local global_map = vim.fn.maparg('K', 'n', false, true).callback
local function settle() vim.wait(15) end
local function count_subscribers()
  local count = 0; for _ in pairs(subscribers) do count = count + 1 end; return count
end
local function session(provider, id, name)
  return {
    provider = provider, session_id = id, name = name or id, generation = '1', cwd = '/project',
    state = 'waiting', aggregate_state = 'waiting', relation = 'root', parent_id = vim.NIL,
    root_id = id, classification = 'resolved', liveness = 'unknown', ordering = 'best_effort',
    last_event_at = '2026-10-04T00:00:00Z', running_descendants = 2, unresolved_requests = 1,
    unresolved_count_exact = true, attention_unknown = false, request_ids = { 'request-one' },
  }
end
-- Matching IDs in different providers must never be treated as the same session.
local claude = session('claude', 'shared-id', 'Claude task')
local codex = session('codex', 'shared-id', 'Codex task')
local function snapshot(entries)
  return { status = 'connected', data = { roots = entries or { claude, codex }, unclassified = {} } }
end
local function publish(value)
  current = value
  local callbacks = {}; for _, callback in pairs(subscribers) do callbacks[#callbacks + 1] = callback end
  for _, callback in ipairs(callbacks) do callback(value) end
  settle()
end
local function press(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'xt', false)
  settle()
end
local function floats()
  local result = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= '' then result[#result + 1] = win end
  end
  return result
end
local seen_buffers, seen_windows = {}, {}
local function popup()
  local wins = floats(); assert(#wins == 1, 'expected one hover, got ' .. #wins)
  local win, buf = wins[1], vim.api.nvim_win_get_buf(wins[1])
  seen_windows[win], seen_buffers[buf] = true, true
  return win, buf
end
local function text(buf) return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n') end
local function no_popup(message) assert(#floats() == 0, message or 'hover survived dismissal') end
local function bounded(win)
  local pos, config = vim.api.nvim_win_get_position(win), vim.api.nvim_win_get_config(win)
  local height, width = vim.api.nvim_win_get_height(win), vim.api.nvim_win_get_width(win)
  assert(width > 0 and height > 0, 'non-positive hover dimensions')
  assert(pos[1] >= 0 and pos[2] >= 0, 'hover starts outside editor')
  local border = config.border and 2 or 0
  assert(pos[1] + height + border <= vim.o.lines - vim.o.cmdheight
    and pos[2] + width + border <= vim.o.columns,
    'hover exceeds editor bounds: ' .. vim.inspect({ pos, width, height, vim.o.columns, vim.o.lines }))
  assert(config.focusable ~= false, 'second K cannot focus hover')
end
local function reply(request, row, err)
  -- Deliberately ignore request.cancelled to model a callback already queued when
  -- cancellation happens. The view must independently guard its own lifetime.
  request.callback(row and vim.deepcopy(row) or nil, err); settle()
end
local function selected(row)
  local state = k.get_state(); vim.api.nvim_set_current_win(state.winid)
  local line
  for index, context in pairs(state.line_meta) do
    local item = context.ctx and context.ctx.item
    if item and ((row and item.session and client.identity(item.session) == client.identity(row))
      or (not row and item.kind == 'provider')) then line = index; break end
  end
  assert(line, 'sidebar row missing')
  vim.api.nvim_win_set_cursor(state.winid, { line, 0 })
  -- Scripted cursor changes do not necessarily run the normal input-loop event.
  vim.api.nvim_exec_autocmds('CursorMoved', { buffer = state.bufnr, modeline = false })
  settle(); return state
end
local home
local function reset(value, columns, lines)
  a.shutdown(); k.close(); settle()
  assert(count_subscribers() == 0, 'previous case leaked subscriptions')
  no_popup()
  vim.cmd('silent! tabonly'); vim.cmd('silent! only')
  home = vim.api.nvim_get_current_win()
  vim.o.columns = columns or 120; vim.o.lines = lines or 40
  current = value or snapshot()
  local component = a.setup({ cap = 10 })
  k.setup({ root = { component }, window = { position = 'left', size = math.min(36, math.floor(vim.o.columns / 2)), padding = 1 } })
  k.open(); settle()
  assert(count_subscribers() == 1, 'sidebar must own exactly one subscription')
end
local function start(row)
  local state = selected(row or claude)
  local before = #requests
  press('K')
  local win, buf = popup()
  assert(#requests == before + 1, 'opening hover must fetch exactly once')
  assert(vim.api.nvim_get_current_win() == state.winid, 'first K stole sidebar focus')
  assert(count_subscribers() == 2, 'hover subscription missing or duplicated')
  bounded(win)
  return win, buf, requests[#requests], state
end
local function closed(win, buf, request, expected_subscribers)
  settle()
  assert(not vim.api.nvim_win_is_valid(win), 'hover window leaked')
  assert(not vim.api.nvim_buf_is_valid(buf), 'hover buffer leaked')
  assert(request.cancelled, 'pending detail request was not cancelled')
  no_popup()
  if expected_subscribers then assert(count_subscribers() == expected_subscribers, 'dismissal leaked subscriptions') end
end

-- K is row-local, and the callable API also rejects unrelated windows/rows.
reset()
a.open_hover(claude); settle(); no_popup('hover opened outside the sidebar')
assert(#requests == 0)
selected(nil); press('K'); a.open_hover(claude); settle()
no_popup('provider header opened a session hover'); assert(#requests == 0)
assert(global_hits == 0, 'header K fell through to global mapping')
selected(claude); a.open_hover(codex); settle()
no_popup('API displayed a session other than the selected row')
local win, buf, request, sidebar = start()
assert(not vim.bo[buf].buflisted and vim.bo[buf].buftype == 'nofile', 'hover must use a scratch buffer')
reply(request, claude)
local detail = text(buf)
for _, field in ipairs({ 'provider', 'session_id', 'generation', 'cwd', 'state', 'aggregate_state',
  'relation', 'parent_id', 'root_id', 'classification', 'liveness', 'ordering', 'last_event_at' }) do
  assert(detail:find(field .. ':', 1, true), 'detail field lost: ' .. field)
end
assert(detail:find('request-one', 1, true), 'own unresolved request IDs lost')
assert(detail:find('Counts are backend aggregates; liveness unknown is not idle.', 1, true), 'detail caveat lost')
assert(not vim.bo[buf].modifiable, 'hover content is editable')
local before = #requests
press('K')
assert(vim.api.nvim_get_current_win() == win, 'second K did not focus existing hover')
assert(#floats() == 1 and vim.api.nvim_win_get_buf(win) == buf and #requests == before, 'second K recreated hover')
press('K')
assert(vim.api.nvim_get_current_win() == sidebar.winid and vim.api.nvim_win_is_valid(win),
  'K in focused hover did not return to sidebar without recreating it')
press('K'); press('q'); closed(win, buf, request, 1)
vim.api.nvim_set_current_win(home)
assert(vim.fn.maparg('K', 'n', false, true).callback == global_map, 'global K mapping changed')
press('K'); assert(global_hits == 1, 'global K no longer works outside sidebar')

-- Repeated open/focus/close works while replies are still pending; even a late
-- NotFound/error response must not resurrect a dismissed view.
for _, key in ipairs({ '<Esc>', 'q', '<Esc>' }) do
  win, buf, request = start()
  press('K'); press(key); closed(win, buf, request, 1)
  reply(request, nil, 'LateNotFound'); no_popup('late error resurrected hover')
  assert(count_subscribers() == 1)
end

-- A canceled callback from a previous opening must not touch its replacement.
local old_win, old_buf, old_request = start()
press('K'); press('q'); closed(old_win, old_buf, old_request, 1)
win, buf, request = start(codex)
reply(request, codex); local replacement_text = text(buf)
reply(old_request, claude)
assert(text(buf) == replacement_text and vim.api.nvim_win_is_valid(win), 'old popup callback changed new popup')
press('K'); press('q'); closed(win, buf, request, 1)

-- Detail errors remain readable in the focused popup and a manual refresh can
-- recover in place, without leaking or accepting the superseded error callback.
win, buf, request = start()
reply(request, nil, 'NotFound')
assert(text(buf):find('NotFound', 1, true), 'detail error was hidden')
press('K'); before = #requests; press('r')
local recovered = requests[#requests]
assert(#requests == before + 1 and request.cancelled, 'manual refresh did not replace request')
reply(recovered, claude); reply(request, nil, 'OldError')
assert(text(buf):find('provider: claude', 1, true) and not text(buf):find('OldError', 1, true),
  'manual refresh accepted stale error')
assert(vim.api.nvim_get_current_win() == win, 'refresh lost focused popup')
press('q'); closed(win, buf, recovered, 1)

-- Moving the sidebar cursor in either dimension invalidates the old anchor.
for _, movement in ipairs({ 'row', 'column' }) do
  reset(); win, buf, request, sidebar = start()
  local position = vim.api.nvim_win_get_cursor(sidebar.winid)
  position[movement == 'row' and 1 or 2] = position[movement == 'row' and 1 or 2] + 1
  vim.api.nvim_win_set_cursor(sidebar.winid, position)
  vim.api.nvim_exec_autocmds('CursorMoved', { buffer = sidebar.bufnr, modeline = false })
  closed(win, buf, request, 1); reply(request, claude); no_popup()
end

-- Window/tab departures and every sidebar teardown path cancel pending work.
for _, action in ipairs({ 'window', 'tab', 'close', 'retain', 'replace', 'window-close', 'hover-close', 'hover-wipe', 'hover-replace' }) do
  reset(); win, buf, request, sidebar = start()
  if action == 'window' then vim.api.nvim_set_current_win(home)
  elseif action == 'tab' then vim.cmd('tabnew')
  elseif action == 'close' then k.close()
  elseif action == 'retain' then k.close({ keep_buffer = true })
  elseif action == 'replace' then
    local replacement = vim.api.nvim_create_buf(false, true)
    vim.bo[replacement].bufhidden = 'wipe'
    vim.api.nvim_win_set_buf(sidebar.winid, replacement)
  elseif action == 'window-close' then vim.api.nvim_win_close(sidebar.winid, true)
  elseif action == 'hover-close' then vim.api.nvim_win_close(win, true)
  elseif action == 'hover-wipe' then vim.api.nvim_buf_delete(buf, { force = true })
  else
    local replacement = vim.api.nvim_create_buf(false, true)
    vim.bo[replacement].bufhidden = 'wipe'
    vim.api.nvim_win_set_buf(win, replacement)
  end
  closed(win, buf, request)
  reply(request, claude); no_popup('delayed reply survived ' .. action)
  if action ~= 'tab' then
    assert(count_subscribers() == ((action == 'window' or action:match('^hover%-')) and 1 or 0), 'subscription leak after ' .. action)
  end
end

-- A new snapshot refreshes the same popup without refocusing it. Results can
-- arrive out of order, including after a newer successful response.
reset(); win, buf, request, sidebar = start()
local changed = vim.deepcopy(claude); changed.generation = '2'; changed.cwd = '/new-project'
publish(snapshot({ codex, changed }))
assert(vim.api.nvim_win_is_valid(win), 'same identity reorder closed hover')
assert(request.cancelled, 'superseded request was not cancelled')
local newer = requests[#requests]; assert(newer ~= request, 'changed snapshot did not refresh detail')
assert(newer.provider == 'claude' and newer.id == 'shared-id', 'refresh confused provider identity')
reply(newer, changed); reply(request, claude)
assert(text(buf):find('generation: 2', 1, true) and text(buf):find('cwd: /new-project', 1, true),
  'stale response replaced newer detail')
assert(vim.api.nvim_get_current_win() == sidebar.winid, 'refresh stole sidebar focus')
before = #requests; publish(current)
assert(#requests == before, 'unchanged snapshot redundantly fetched detail')
local earlier = session('claude', 'aaa', 'New earlier session')
publish(snapshot({ earlier, changed, codex }))
closed(win, buf, newer, 1)
reply(newer, changed); no_popup('redraw identity change resurrected hover')

reset(); win, buf, request = start(codex)
assert(request.provider == 'codex', 'K fetched wrong provider for shared session ID')
publish(snapshot({ claude }))
closed(win, buf, request, 1); reply(request, codex); no_popup('removed row resurrected hover')

-- A terminal transition can move a row behind its active sibling. The old
-- anchor must close rather than display completed details on a different row.
local sibling = session('claude', 'zz-sibling', 'Still active')
reset(snapshot({ claude, sibling, codex })); win, buf, request = start()
local ended = vim.deepcopy(claude)
ended.state = 'ended'; ended.aggregate_state = 'ended'; ended.running_descendants = 0
ended.unresolved_requests = 0; ended.unresolved_count_exact = true; ended.attention_unknown = false; ended.request_ids = {}
publish(snapshot({ ended, sibling, codex }))
closed(win, buf, request, 1); reply(request, ended); no_popup('terminal reorder resurrected stale hover')
win, buf, request = start(ended); reply(request, ended)
assert(text(buf):find('aggregate_state: ended', 1, true), 'reordered ended history lost K detail')
press('K'); press('q'); closed(win, buf, request, 1)

-- Ending the parent alone does not reorder or close an active subtree hover.
reset(snapshot({ claude, sibling, codex })); win, buf, request = start()
local active_parent = vim.deepcopy(claude); active_parent.state = 'ended'
publish(snapshot({ active_parent, sibling, codex }))
assert(vim.api.nvim_win_is_valid(win), 'ended parent with waiting descendants was deprioritized')
local refreshed = requests[#requests]; reply(refreshed, active_parent)
assert(text(buf):find('state: ended', 1, true) and text(buf):find('aggregate_state: waiting', 1, true))
press('K'); press('q'); closed(win, buf, refreshed, 1)

-- Resizes dismiss anchored content, and a fresh open remains bounded even in a
-- small terminal. Check both pending and already-rendered popups.
for _, size in ipairs({ { 80, 24 }, { 24, 10 }, { 16, 6 } }) do
  reset(nil, size[1], size[2]); win, buf, request = start()
  local long = vim.deepcopy(claude); long.cwd = string.rep('/日本語-project', 80)
  long.request_ids = {}; for i = 1, 100 do long.request_ids[i] = 'request-' .. i end
  reply(request, long); bounded(win)
  vim.api.nvim_exec_autocmds('VimResized', { modeline = false })
  closed(win, buf, request, 1)
  win, buf, request = start()
  vim.api.nvim_exec_autocmds('VimResized', { modeline = false })
  closed(win, buf, request, 1); reply(request, long); no_popup()
end

-- Enter still opens the existing split detail view, rather than the new hover.
reset()
local window_count = #vim.api.nvim_list_wins()
win, buf, request = start()
press('<CR>'); closed(win, buf, request, 2)
no_popup('Enter unexpectedly opened a float')
assert(#vim.api.nvim_list_wins() == window_count + 1, 'Enter stopped opening split detail')
assert(vim.api.nvim_buf_get_name(0) == 'mimori://detail', 'Enter changed detail destination')
reply(requests[#requests], claude)
assert(text(0):find('classification: resolved', 1, true), 'split detail fields lost')
press('q'); settle(); assert(count_subscribers() == 1, 'split detail subscription leaked')

-- Shutdown cleans an active hover too, including a callback already in flight.
win, buf, request = start(); a.shutdown(); k.close()
closed(win, buf, request, 0); reply(request, claude); no_popup()
assert(next(subscribers) == nil, 'final subscription leaked')
for _, autocmd in ipairs(vim.api.nvim_get_autocmds({})) do
  assert(not (autocmd.group_name or ''):match('^MimoriHover'), 'hover autocmd group leaked')
end
for _, pending_request in ipairs(requests) do assert(pending_request.cancelled, 'detail request leaked') end
for id in pairs(seen_windows) do assert(not vim.api.nvim_win_is_valid(id), 'old hover window survived') end
for id in pairs(seen_buffers) do assert(not vim.api.nvim_buf_is_valid(id), 'old hover buffer survived') end
for _, id in ipairs(vim.api.nvim_list_bufs()) do
  assert(not vim.api.nvim_buf_get_name(id):match('^mimori://'), 'mimori scratch buffer leaked')
end
assert(vim.fn.maparg('K', 'n', false, true).callback == global_map, 'shutdown changed global K')
print('hover: passed; row-local K, focus/close, stale/reordered replies, teardown, resize, small terminals and split detail verified')
