local M = {}

local status = {
  done = "✓", active = "●", pending = "○", paused = "Ⅱ", blocked = "!", retired = "–",
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

local function chunks(text, width)
  local rows, chunk, len = {}, {}, 0
  for _, char in ipairs(vim.fn.split(text, "\\zs")) do
    local size = cells(char)
    if len + size > width and #chunk > 0 then
      rows[#rows + 1] = table.concat(chunk)
      chunk, len = {}, 0
    end
    chunk[#chunk + 1], len = char, len + size
  end
  rows[#rows + 1] = table.concat(chunk)
  return rows
end

-- The journal is in sequence order. Project only user-facing records, never
-- event IDs, source IDs, sequence numbers, payload dumps or control receipts.
local function recent(snapshot)
  local rows, previous = {}, {}
  local function record(event, text)
    local time = (event.at or ""):match("T(%d%d:%d%d):%d%d[%d.]*Z$")
    if not time or text == "" then return end
    rows[#rows + 1] = time .. "  " .. text
    if #rows > 5 then table.remove(rows, 1) end
  end
  for _, event in ipairs(snapshot.events or {}) do
    local p = event.payload
    if type(p) == "table" then
      if event.kind == "report.add" then
        record(event, clean(p.summary))
      elseif event.kind == "task.upsert" and p.id and changes[p.status] then
        if previous[p.id] and previous[p.id] ~= p.status then
          record(event, changes[p.status] .. clean(p.title))
        end
        previous[p.id] = p.status
      elseif event.kind == "discussion.add" and event.source == "interval-progress-v1"
          and p.id == event.event_id and p.target_type == "task" then
        local category = tostring(p.id):match("^progress%-([a-z]+)%-.+$")
        if category == "result" or category == "blocker" or category == "next" then
          record(event, clean(p.text))
        end
      end
    end
  end
  return rows
end

function M.rows(view, width, expanded)
  local rows = {}
  local function add(text)
    vim.list_extend(rows, chunks(text, width))
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
  if cells(title) > room then
    title = chunks(title, room - cells("…"))[1] .. "…"
  end
  add(title .. string.rep(" ", width - cells(title) - cells(percent)) .. percent)
  local bar_width = math.floor(width / math.max(cells("━"), cells("─")))
  local filled = math.floor(fraction * bar_width + 0.5)
  add(string.rep("━", filled) .. string.rep("─", bar_width - filled))
  if not expanded then return rows end

  local children = {}
  for _, task in ipairs(snapshot.tasks or {}) do
    local parent = task.parent_id or ""
    children[parent] = children[parent] or {}
    table.insert(children[parent], task)
  end
  local function tasks(parent, depth)
    for _, task in ipairs(children[parent] or {}) do
      if task.status ~= "retired" then
        add(string.rep("  ", math.min(depth, 4)) .. (status[task.status] or "?") .. " " .. clean(task.title))
        tasks(task.id, depth + 1)
      end
    end
  end
  local before_tasks = #rows
  tasks("", 0)
  if #rows == before_tasks then add("タスクなし") end

  add("")
  add("最近の更新 (UTC)")
  local updates = recent(snapshot)
  if #updates == 0 then add("更新なし") end
  for index = #updates, 1, -1 do add(updates[index]) end
  return rows
end

return M
