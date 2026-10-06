-- Thin adapter: visibility owns subscriptions; all render providers read cache.
local client = require("mimori.client")
local M = {}
local release, group, pending, komado, cap, view, detail_view, all_view, status_view
local hover_view
local close_hover
local generation = 0
local highlights = vim.api.nvim_create_namespace("mimori.states")
local event = "MimoriViewChanged"
local known = { running = true, idle = true, ended = true, waiting = true, unknown = true }
local function clean(value, width)
  local text = tostring(value or "?"):gsub("\27%[[0-?]*[ -/]*[@-~]", ""):gsub("\27%][^\7]*\7", "")
  text = text:gsub("[%c]", " ")
  -- Also strip Unicode line/control separators used to spoof displayed rows.
  text = text:gsub("\194[\128-\159]", " "):gsub("\226\128[\168-\174]", " "):gsub("\226\129[\166-\169]", " ")
  width = math.max(1, width or 120)
  if vim.fn.strdisplaywidth(text) <= width then return text end
  local ellipsis = vim.fn.strdisplaywidth("…") <= width and "…" or "."
  local result = ""
  for _, c in ipairs(vim.fn.split(text, "\\zs")) do
    if vim.fn.strdisplaywidth(result .. c .. ellipsis) > width then break end
    result = result .. c
  end
  return result .. ellipsis
end
M.clean = clean
local function state_label(s) return known[s] and s or ("unknown (" .. clean(s, 30) .. ")") end
local function waiting(r) return r.unresolved_requests > 0 or r.attention_unknown or not r.unresolved_count_exact end
local function label(r)
  local n = tostring(r.unresolved_requests) .. (r.unresolved_count_exact and "" or "+?")
  return string.format("%s · %s · child %d · wait %s%s", r.name or r.session_id, state_label(r.aggregate_state), r.running_descendants, n,
    r.attention_unknown and " attention?" or "")
end
-- Text presentation uses one display cell per transport glyph, including when
-- ambiwidth=double makes the Unicode marks wider. No icon font is required.
local function status_icon(status)
  local glyph, fallback = "!", "!"
  if status == "connected" then glyph, fallback = "●", "+"
  elseif status == "loading" then glyph, fallback = "◌", "~"
  elseif status == "paused" then glyph, fallback = "○", "-" end
  return vim.fn.strdisplaywidth(glyph) == 1 and glyph or fallback
end
M.status_icon = status_icon
local states = {
  running = { "▶", ">", "MimoriRunning", "DiagnosticOk" },
  waiting = { "◆", "!", "MimoriWaiting", "DiagnosticWarn" },
  idle = { "○", "-", "MimoriIdle", "Comment" },
  ended = { "■", "x", "MimoriEnded", "NonText" },
  unknown = { "?", "?", "MimoriUnknown", "DiagnosticInfo" },
}
local function setup_highlights()
  for _, s in pairs(states) do vim.api.nvim_set_hl(0, s[3], { default = true, link = s[4] }) end
end
local function state_icon(state)
  local s = states[state] or states.unknown
  return vim.fn.strdisplaywidth(s[1]) == 1 and s[1] or s[2], s[3]
end
M.state_icon = state_icon
local function summary(r)
  local count = tostring(r.unresolved_requests) .. (r.unresolved_count_exact and "" or "+?")
  -- Identity/name is last so truncation preserves the state and both counts.
  return string.format("%s W%s R%d%s %s", state_icon(r.aggregate_state), count,
    r.running_descendants, r.classification ~= "resolved" and " ~" or "", r.name or r.session_id)
end
local function rows(snapshot, limit)
  local groups = { { key = "claude", title = "Claude", entries = {} }, { key = "codex", title = "Codex", entries = {} } }
  local by_provider = { claude = groups[1], codex = groups[2] }
  if snapshot.data then
    for _, set in ipairs({ snapshot.data.roots, snapshot.data.unclassified }) do
      for _, row in ipairs(set) do
        local provider = row.provider
        if not by_provider[provider] then
          by_provider[provider] = { key = provider, title = "Other: " .. provider, entries = {} }
          groups[#groups + 1] = by_provider[provider]
        end
        table.insert(by_provider[provider].entries, row)
      end
    end
  end
  table.sort(groups, function(a, b)
    local rank = { claude = 1, codex = 2 }
    local x, y = rank[a.key] or 3, rank[b.key] or 3
    return x == y and a.key < b.key or x < y
  end)
  for _, g in ipairs(groups) do
    table.sort(g.entries, function(a, b) return a.session_id < b.session_id end)
    g.shown = limit and 0 or #g.entries
  end
  -- One shared row budget; round-robin allocation prevents one provider from
  -- consuming every slot. Group order and each provider's identity order stay stable.
  local remaining = limit or 0
  while remaining > 0 do
    local progressed = false
    for _, g in ipairs(groups) do
      if remaining > 0 and g.shown < #g.entries then
        g.shown = g.shown + 1; remaining = remaining - 1; progressed = true
      end
    end
    if not progressed then break end
  end
  local result = {}
  for _, g in ipairs(groups) do
    result[#result + 1] = { text = status_icon(snapshot.status) .. " " .. g.title
      .. (snapshot.data and #g.entries == 0 and " —" or ""), kind = "provider" }
    for i = 1, g.shown do
      local icon, hl = state_icon(g.entries[i].aggregate_state)
      result[#result + 1] = { text = summary(g.entries[i]), icon = icon, hl = hl, session = g.entries[i], kind = "session" }
    end
    if g.shown < #g.entries then
      local waits = 0
      for i = g.shown + 1, #g.entries do if waiting(g.entries[i]) then waits = waits + 1 end end
      result[#result + 1] = { text = string.format("+%d more · wait %d · a", #g.entries - g.shown, waits), kind = "more" }
    end
  end
  return result
end
M.rows = rows
local function row_tail(row, width)
  if not row.icon then return clean(row.text, width) end
  if width <= 1 then return "" end
  -- Split the known UTF-8 prefix before truncating: the ellipsis may
  -- otherwise replace a one-byte ASCII icon and be sliced mid-codepoint.
  return clean(row.text:sub(#row.icon + 1), width - 1)
end
local function changed()
  pcall(vim.api.nvim_exec_autocmds, "User", { pattern = event, modeline = false })
end
local function visible()
  if not komado then return false end
  local s = komado.get_state()
  return s and s.winid and s.bufnr and vim.api.nvim_win_is_valid(s.winid)
    and vim.api.nvim_buf_is_valid(s.bufnr) and vim.api.nvim_win_get_buf(s.winid) == s.bufnr
    and vim.api.nvim_win_get_tabpage(s.winid) == vim.api.nvim_get_current_tabpage()
end
M.visible = visible
local function write(v, text)
  if not v or not vim.api.nvim_buf_is_valid(v.buf) then return end
  vim.bo[v.buf].modifiable = true
  vim.api.nvim_buf_set_lines(v.buf, 0, -1, false, text)
  vim.bo[v.buf].modifiable = false
end
local function render_all(v, snapshot)
  if v.closed or not vim.api.nvim_win_is_valid(v.win) or not vim.api.nvim_buf_is_valid(v.buf)
    or vim.api.nvim_win_get_buf(v.win) ~= v.buf then return end
  local selected
  if v.rows and vim.api.nvim_win_is_valid(v.win) then
    local old = v.rows[vim.api.nvim_win_get_cursor(v.win)[1]]
    selected = old and old.session and client.identity(old.session)
  end
  v.rows = rows(snapshot)
  local lines, line = {}, nil
  for i, row in ipairs(v.rows) do
    lines[i] = (row.icon or "") .. row_tail(row, vim.api.nvim_win_get_width(v.win) - 2)
    if selected and row.session and client.identity(row.session) == selected then line = i end
  end
  write(v, lines)
  vim.api.nvim_buf_clear_namespace(v.buf, highlights, 0, -1)
  for i, row in ipairs(v.rows) do
    if row.icon then
      vim.api.nvim_buf_set_extmark(v.buf, highlights, i - 1, 0, { end_col = #row.icon, hl_group = row.hl })
    end
  end
  if line then pcall(vim.api.nvim_win_set_cursor, v.win, { line, 0 }) end
end
local function dispose(v, defer)
  if not v or v.closed then return end
  v.closed = true
  if v.release then v.release(); v.release = nil end
  if v.cancel then v.cancel() end
  if v.group then pcall(vim.api.nvim_del_augroup_by_id, v.group) end
  local function cleanup()
    if vim.api.nvim_buf_is_valid(v.buf) then pcall(vim.api.nvim_buf_delete, v.buf, { force = true }) end
  end
  if defer then vim.schedule(cleanup) else cleanup() end
end
local function subscribe_view(v)
  if v.closed or not v.callback then return end
  local shown = vim.api.nvim_win_is_valid(v.win) and vim.api.nvim_buf_is_valid(v.buf)
    and vim.api.nvim_win_get_buf(v.win) == v.buf
    and vim.api.nvim_win_get_tabpage(v.win) == vim.api.nvim_get_current_tabpage()
  if shown and not v.release then
    if v.resume then v.resume() end
    v.release = client.subscribe(v.callback)
  elseif not shown and v.release then
    v.release(); v.release = nil
    if v.cancel then v.cancel(); v.cancel = nil end
  end
end
local function open_view(name)
  vim.cmd("botright vsplit")
  local v = { win = vim.api.nvim_get_current_win(), buf = vim.api.nvim_create_buf(false, true) }
  vim.api.nvim_win_set_buf(v.win, v.buf)
  vim.api.nvim_buf_set_name(v.buf, "mimori://" .. name)
  vim.bo[v.buf].buftype = "nofile"; vim.bo[v.buf].bufhidden = "wipe"; vim.bo[v.buf].swapfile = false
  vim.bo[v.buf].filetype = "mimori"; vim.wo[v.win].wrap = false
  v.group = vim.api.nvim_create_augroup("MimoriView" .. v.buf, { clear = true })
  vim.api.nvim_create_autocmd({ "WinClosed", "BufWipeout", "TabEnter", "TabLeave", "BufWinEnter", "BufWinLeave" }, {
    group = v.group, callback = function()
      vim.schedule(function()
        if v.closed then return end
        if not vim.api.nvim_win_is_valid(v.win) or not vim.api.nvim_buf_is_valid(v.buf)
          or vim.api.nvim_win_get_buf(v.win) ~= v.buf then dispose(v) else subscribe_view(v) end
      end)
    end,
  })
  vim.keymap.set("n", "q", function() dispose(v) end, { buffer = v.buf })
  vim.keymap.set("n", "r", client.refresh, { buffer = v.buf })
  vim.keymap.set("n", "?", M.open_status, { buffer = v.buf })
  vim.keymap.set("n", "a", M.open_all, { buffer = v.buf })
  return v
end
function M.open_status()
  close_hover()
  dispose(status_view)
  local v = open_view("status"); status_view = v
  v.callback = function(snapshot)
    local lines = { "mimori status", "Connection: " .. snapshot.status,
      "Observations: " .. (snapshot.data and (snapshot.status == "connected" and "connected snapshot" or "retained snapshot") or "not received") }
    if snapshot.diagnostic then lines[#lines + 1] = "Transport: " .. clean(snapshot.diagnostic, 16384) end
    if snapshot.collector_diagnostic then
      lines[#lines + 1] = "Historical collector error: " .. clean(snapshot.collector_diagnostic.observed_at, 120)
      lines[#lines + 1] = clean(snapshot.collector_diagnostic.message, 4096)
    end
    vim.list_extend(lines, { "", "●/+ connected; ◌/~ connecting; ○/- paused; ! error",
      "W: unresolved requests; +? includes an unknown remainder",
      "R: running descendants (not all children)",
      "~ before a name: hierarchy is not resolved; Enter shows why",
      "▶/> running; ◆/! waiting; ○/- idle; ■/x ended; ? unknown",
      "State colors: DiagnosticOk / DiagnosticWarn / Comment / NonText / DiagnosticInfo",
      "Unknown state/liveness is never inferred as idle or ended",
      "K: hover detail; K again: focus; q/Esc in hover: close; Enter: split detail",
      "— after provider: no observations in this snapshot",
      "a: all · r: retry/refresh · q: close" })
    write(v, lines)
  end
  vim.wo[v.win].wrap = true
  subscribe_view(v)
end
local function detail_lines(row)
  local lines = { "mimori detail", label(row) }
  for _, k in ipairs({ "provider", "session_id", "generation", "cwd", "state", "aggregate_state", "relation", "parent_id", "root_id", "classification", "liveness", "ordering", "last_event_at" }) do
    lines[#lines + 1] = k .. ": " .. tostring(row[k] or "—")
  end
  lines[#lines + 1] = "Own unresolved request IDs:"
  for _, id in ipairs(row.request_ids == vim.NIL and {} or row.request_ids) do lines[#lines + 1] = "  " .. id end
  lines[#lines + 1] = "Counts are backend aggregates; liveness unknown is not idle."
  for i, line in ipairs(lines) do lines[i] = clean(line, 4096) end
  return lines
end
function M.open_detail(root)
  close_hover()
  dispose(detail_view)
  local v = open_view("detail"); detail_view = v
  vim.wo[v.win].wrap = true
  local key = client.identity(root)
  local function fetch()
    if v.cancel then v.cancel() end
    v.cancel = client.detail(root.provider, root.session_id, function(row, err)
      if v.closed then return end
      if not row then write(v, { clean(err), "r: refresh · q: close" }); return end
      local lines = detail_lines(row)
      write(v, lines)
    end)
  end
  local last
  v.resume = function() last = nil end
  v.callback = function(snapshot)
    if v.closed or not snapshot.data then return end
    local found
    for _, set in ipairs({ snapshot.data.roots, snapshot.data.unclassified }) do
      for _, row in ipairs(set) do if client.identity(row) == key then found = row end end
    end
    if last ~= snapshot.data then last = snapshot.data; fetch() end
    if not found then write(v, { "NotFound", "r: refresh · q: close" }) end
  end
  subscribe_view(v)
  vim.keymap.set("n", "r", function() client.refresh(); fetch() end, { buffer = v.buf })
  if not last then write(v, { "Loading…" }) end
end
-- A sidebar-owned hover, separate from Neovim's LSP preview state/mappings.
local function hover_selected(v)
  if v.closed or not visible() then return false end
  local s = komado.get_state()
  if s.winid ~= v.source_win or s.bufnr ~= v.source_buf then return false end
  if not vim.deep_equal(v.cursor, vim.api.nvim_win_get_cursor(v.source_win)) then return false end
  local ctx = s:get_context()
  local row = ctx and ctx.ctx and ctx.ctx.item
  return row and row.session and client.identity(row.session) == v.key
end
close_hover = function(defer)
  local v = hover_view
  hover_view = nil
  if not v then return end
  dispose(v, defer == true)
  local function cleanup()
    if vim.api.nvim_win_is_valid(v.win) then pcall(vim.api.nvim_win_close, v.win, true) end
  end
  if defer == true then vim.schedule(cleanup) else cleanup() end
end
local function hover_config(v, lines)
  local width = math.max(1, math.min(80, vim.o.columns - 2))
  local height = 0
  for _, line in ipairs(lines) do height = height + math.max(1, math.ceil(vim.fn.strdisplaywidth(line) / width)) end
  height = math.max(1, math.min(20, vim.o.lines - vim.o.cmdheight - 2, height))
  local pos = vim.fn.screenpos(v.source_win, v.cursor[1], v.cursor[2] + 1)
  local bottom = vim.o.lines - vim.o.cmdheight
  local row = pos.row
  if row + height + 2 > bottom then row = math.max(0, pos.row - height - 2) end
  return { relative = "editor", row = row, col = math.max(0, math.min(pos.col - 1, vim.o.columns - width - 2)),
    width = width, height = height, style = "minimal", border = "rounded", title = " mimori ", focusable = true }
end
function M.open_hover(root)
  local s = komado and komado.get_state()
  if not visible() or vim.api.nvim_get_current_win() ~= s.winid then return end
  local key = client.identity(root)
  if hover_view and hover_view.key == key and hover_selected(hover_view)
    and vim.api.nvim_win_is_valid(hover_view.win) then
    vim.api.nvim_set_current_win(hover_view.win)
    return
  end
  close_hover()
  local v = { source_win = s.winid, source_buf = s.bufnr, cursor = vim.api.nvim_win_get_cursor(s.winid), key = key }
  if not hover_selected(v) then return end
  v.buf = vim.api.nvim_create_buf(false, true)
  v.win = vim.api.nvim_open_win(v.buf, false, hover_config(v, { "Loading…" }))
  hover_view = v
  vim.api.nvim_buf_set_name(v.buf, "mimori://hover/" .. v.buf)
  vim.bo[v.buf].bufhidden = "wipe"; vim.bo[v.buf].filetype = "mimori"; vim.bo[v.buf].swapfile = false
  vim.wo[v.win].wrap = true
  write(v, { "Loading…" })
  v.group = vim.api.nvim_create_augroup("MimoriHover" .. v.buf, { clear = true })
  local function active()
    local win = vim.api.nvim_get_current_win()
    return hover_view == v and vim.api.nvim_win_is_valid(v.win) and vim.api.nvim_buf_is_valid(v.buf)
      and vim.api.nvim_win_get_buf(v.win) == v.buf and hover_selected(v) and (win == v.source_win or win == v.win)
  end
  local function validate()
    if hover_view == v and not active() then close_hover() end
  end
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter" }, {
    group = v.group, buffer = v.source_buf, callback = function() if hover_view == v then close_hover() end end,
  })
  vim.api.nvim_create_autocmd({ "TabLeave", "VimResized" }, { group = v.group, callback = close_hover })
  vim.api.nvim_create_autocmd("WinEnter", { group = v.group, callback = function() vim.schedule(validate) end })
  vim.api.nvim_create_autocmd("User", { group = v.group, pattern = "KomadoRenderPost", callback = validate })
  vim.api.nvim_create_autocmd("WinClosed", { group = v.group, callback = function(args)
    if tonumber(args.match) == v.win or tonumber(args.match) == v.source_win then close_hover() end
  end })
  vim.api.nvim_create_autocmd({ "BufWipeout", "BufWinLeave" }, { group = v.group, callback = function(args)
    -- Invalidate/cancel now; deleting a buffer inside its BufWinLeave/BufWipeout
    -- event can abort an otherwise valid buffer switch with E937.
    if args.buf == v.source_buf or args.buf == v.buf then close_hover(true) end
  end })
  for _, keymap in ipairs({ "q", "<Esc>" }) do vim.keymap.set("n", keymap, close_hover, { buffer = v.buf, nowait = true }) end
  vim.keymap.set("n", "K", function() if active() then vim.api.nvim_set_current_win(v.source_win) end end, { buffer = v.buf })
  local request_id, last = 0, nil
  local function fetch()
    request_id = request_id + 1
    local id = request_id
    if v.cancel then v.cancel(); v.cancel = nil end
    v.cancel = client.detail(root.provider, root.session_id, function(row, err)
      if id ~= request_id or not active() then validate(); return end
      local lines = row and detail_lines(row) or { clean(err), "r: refresh · q/Esc: close" }
      write(v, lines)
      vim.api.nvim_win_set_config(v.win, hover_config(v, lines))
    end)
  end
  v.callback = function(snapshot)
    if not active() then validate(); return end
    if snapshot.data and last ~= snapshot.data then last = snapshot.data; fetch() end
  end
  -- The popup participates in normal visibility ownership, with no independent timer.
  v.release = client.subscribe(v.callback)
  if not last then fetch() end
  vim.keymap.set("n", "r", function() client.refresh(); fetch() end, { buffer = v.buf })
end
function M.open_all()
  close_hover()
  dispose(all_view)
  local v = open_view("all"); all_view = v
  v.callback = function(snapshot) if not v.closed then render_all(v, snapshot) end end
  subscribe_view(v)
  vim.keymap.set("n", "<CR>", function()
    local row = v.rows[vim.api.nvim_win_get_cursor(v.win)[1]]
    if row and row.session then M.open_detail(row.session) end
  end, { buffer = v.buf })
end
local function check()
  pending = false
  if visible() and not release then
    release = client.subscribe(function(snapshot) view = snapshot; changed() end)
  elseif not visible() and release then release(); release = nil; view = client.snapshot() end
end
local function recheck()
  if pending then return end
  pending = true
  local epoch = generation
  vim.schedule(function() if epoch == generation then check() end end)
end
function M.shutdown()
  generation = generation + 1; pending = false
  if release then release(); release = nil end
  close_hover()
  dispose(all_view); dispose(detail_view); dispose(status_view)
  all_view = nil; detail_view = nil; status_view = nil
  if group then pcall(vim.api.nvim_del_augroup_by_id, group); group = nil end
end
function M.setup(opts)
  M.shutdown()
  opts = opts or {}; cap = opts.cap or 10
  assert(cap > 0 and cap == math.floor(cap), "cap must be a positive integer")
  komado = require("komado"); view = client.snapshot()
  setup_highlights()
  group = vim.api.nvim_create_augroup("MimoriKomado", { clear = true })
  vim.api.nvim_create_autocmd("User", { group = group, pattern = { "KomadoWindowAfterOpen", "KomadoWindowAfterClose" }, callback = recheck })
  vim.api.nvim_create_autocmd({ "TabEnter", "TabLeave", "WinEnter", "WinClosed", "BufWinEnter", "BufWinLeave", "BufWipeout" }, { group = group, callback = recheck })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = function()
    setup_highlights()
    if all_view and not all_view.closed then render_all(all_view, client.snapshot()) end
    changed()
  end })
  vim.api.nvim_create_autocmd("VimLeavePre", { group = group, callback = M.shutdown })
  vim.api.nvim_create_user_command("MimoriAll", M.open_all, {})
  vim.api.nvim_create_user_command("MimoriRefresh", client.refresh, {})
  vim.api.nvim_create_user_command("MimoriStatus", M.open_status, {})
  recheck()
  local utils, Line = require("komado.utils"), require("komado.dsl").Line
  return {
    update = { "User", pattern = event },
    utils.mapped_list(function() return rows(view, cap) end, function(item)
      return Line({
        mappings = {
          a = M.open_all,
          ["?"] = M.open_status,
          r = client.refresh,
          K = function(_, ctx)
            local row = ctx.ctx.item
            if row.session then M.open_hover(row.session) end
          end,
          ["<CR>"] = function(_, ctx)
            local row = ctx.ctx.item
            if row.session then M.open_detail(row.session) else M.open_all() end
          end,
        },
        { provider = item.icon or "", hl = item.hl },
        { provider = function(self)
          local s = self._sidebar and self._sidebar._state
          local width = s and s._content_width or 36
          return row_tail(item, width)
        end },
        hl = item.kind == "provider" and "Title" or nil,
      })
    end),
  }
end
return M
