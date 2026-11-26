local M = {}

local status = {
  done = { "✓", "DiagnosticOk" },
  active = { "●", "DiagnosticInfo" },
  pending = { "○", "Comment" },
  paused = { "Ⅱ", "DiagnosticWarn" },
  blocked = { "!", "DiagnosticError" },
}
local changes = {
  done = "完了: ", active = "開始: ", pending = "未着手に戻した: ", paused = "一時停止: ",
  blocked = "ブロック: ", retired = "終了: ",
}

local function clean(text)
  return tostring(text or ""):gsub("[%c]", " ")
end

local function cells(text)
  return vim.fn.strdisplaywidth(text)
end

function M.fit(text, width)
  if cells(text) <= width then return text end
  local room = width - cells("…")
  if room < 0 then return "" end
  local prefix = ""
  for _, char in ipairs(vim.fn.split(text, "\\zs")) do
    if cells(prefix .. char) > room then break end
    prefix = prefix .. char
  end
  return prefix .. "…"
end

local month_start = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 }
local function leap_days(year)
  return math.floor(year / 4) - math.floor(year / 100) + math.floor(year / 400)
end

local function local_time(at)
  local captures = { (at or ""):match("^(%d%d%d%d)-(%d%d)-(%d%d)T(%d%d):(%d%d):(%d%d)[%d.]*Z$") }
  local y, m, d, h, min, sec = unpack(vim.tbl_map(tonumber, captures))
  if not m or not month_start[m] then return end
  -- Track journals store UTC. Convert to an epoch without interpreting the UTC
  -- fields as local wall time, then let os.date apply the local offset at that instant.
  local days = 365 * (y - 1970) + leap_days(y - 1) - leap_days(1969) + month_start[m] + d - 1
  if m > 2 then days = days + leap_days(y) - leap_days(y - 1) end
  return os.date("%H:%M", (((days * 24 + h) * 60 + min) * 60) + sec)
end

-- The journal is in sequence order. Project only user-facing records, never
-- event IDs, source IDs, sequence numbers, payload dumps or control receipts.
local function recent(snapshot)
  local rows, previous = {}, {}
  local function record(event, text)
    local time = local_time(event.at)
    if not time or clean(text) == "" then return end
    rows[#rows + 1] = time .. "  " .. text
    if #rows > 5 then table.remove(rows, 1) end
  end
  for _, event in ipairs(snapshot.events or {}) do
    local p = event.payload
    if type(p) == "table" then
      if event.kind == "report.add" then
        record(event, p.summary or "")
      elseif event.kind == "task.upsert" and p.id and changes[p.status] then
        if previous[p.id] and previous[p.id] ~= p.status then
          record(event, changes[p.status] .. (p.title or ""))
        end
        previous[p.id] = p.status
      elseif event.kind == "discussion.add" and event.source == "interval-progress-v1"
          and p.id == event.event_id and p.target_type == "task" then
        local category = tostring(p.id):match("^progress%-([a-z]+)%-.+$")
        if category == "result" or category == "blocker" or category == "next" then
          record(event, p.text or "")
        end
      end
    end
  end
  return rows
end

function M.rows(view, width)
  local rows = {}
  if width <= 0 then return rows end
  local function add(text, detail)
    rows[#rows + 1] = { text = M.fit(clean(text), width), detail = detail }
  end
  if view.error then add("Timeline の更新に失敗") end
  local snapshot = view.snapshot
  if not snapshot then
    if not view.error then add("Timeline を読み込み中…") end
    return rows
  end

  local fraction = math.max(0, math.min(1, (snapshot.progress or {}).fraction or 0))
  local percent = ("%.0f%%"):format(fraction * 100)
  local title = clean(snapshot.title)
  local room = width - cells(percent) - 1
  if room > 0 then
    local short = M.fit(title, room)
    add(short .. string.rep(" ", width - cells(short) - cells(percent)) .. percent, title .. "  " .. percent)
  else
    add(percent, title .. "  " .. percent)
  end
  local bar_width = math.floor(width / math.max(cells("█"), cells("░")))
  local filled = math.floor(fraction * bar_width + 0.5)
  add(string.rep("█", filled) .. string.rep("░", bar_width - filled))

  local children = {}
  for _, task in ipairs(snapshot.tasks or {}) do
    local parent = task.parent_id or ""
    children[parent] = children[parent] or {}
    table.insert(children[parent], task)
  end
  local function tasks(parent, depth)
    for _, task in ipairs(children[parent] or {}) do
      if task.status ~= "retired" then
        local indent = string.rep("  ", math.min(depth, 4))
        local icon, hl = unpack(status[task.status] or { "?", "Comment" })
        local task_title = task.title or ""
        local detail = icon .. " " .. task_title
        if task.detail and task.detail ~= "" then detail = detail .. "\n\n" .. task.detail end
        if cells(indent .. icon) <= width then
          rows[#rows + 1] = {
            prefix = indent, icon = icon, hl = hl, detail = detail,
            text = M.fit(" " .. clean(task_title), width - cells(indent .. icon)),
          }
        else
          add(icon .. " " .. task_title, detail)
        end
        tasks(task.id, depth + 1)
      end
    end
  end
  local before_tasks = #rows
  tasks("", 0)
  if #rows == before_tasks then add("タスクなし") end

  add("")
  add("最近の更新")
  local updates = recent(snapshot)
  if #updates == 0 then add("更新なし") end
  for index = #updates, 1, -1 do add(updates[index], updates[index]) end
  return rows
end

function M.preview(detail)
  local lines = vim.split(detail:gsub("\r\n", "\n"):gsub("\r", "\n"), "\n", { plain = true })
  lines = vim.tbl_map(clean, lines)
  local origin = vim.api.nvim_get_current_win()
  local cursor_col = vim.fn.win_screenpos(origin)[2] + vim.fn.wincol() - 2
  local max_width = math.max(1, math.min(80, vim.o.columns - 2))
  -- Use the editor width for sizing, then anchor the new float to the cursor.
  local _, float = vim.lsp.util.open_floating_preview(lines, "text", {
    relative = "editor", border = "rounded", focus_id = "komado_timeline_detail",
    max_width = max_width, wrap_at = max_width, max_height = 12,
  })
  if vim.api.nvim_get_current_win() ~= origin then return end -- Repeated K focuses the existing preview.
  local config = vim.api.nvim_win_get_config(float)
  local left = math.min(cursor_col, math.max(0, vim.o.columns - config.width - 2))
  vim.api.nvim_win_set_config(float, {
    relative = "cursor", anchor = config.anchor:sub(1, 1) .. "W",
    row = config.row, col = left - cursor_col,
  })
end

return M
