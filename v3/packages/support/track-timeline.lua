local M = {}

local function value(x)
  if x == nil then return "" end
  return tostring(x):gsub("[%c]", " ")
end

-- Komado uses nowrap. Wrap details by display cells without losing records,
-- including long payloads or text without spaces.
local function append_wrapped(rows, text, width)
  if vim.fn.strdisplaywidth(text) <= width then
    rows[#rows + 1] = text
    return
  end
  local chunk, cells = {}, 0
  for _, char in ipairs(vim.fn.split(text, "\\zs")) do
    local size = vim.fn.strdisplaywidth(char)
    if cells + size > width and #chunk > 0 then
      rows[#rows + 1] = table.concat(chunk)
      chunk, cells = {}, 0
    end
    chunk[#chunk + 1], cells = char, cells + size
  end
  rows[#rows + 1] = table.concat(chunk)
end

function M.details(view, width)
  local rows = {}
  local function add(text) append_wrapped(rows, text, width) end
  if view.error then add("Unavailable or stale: " .. value(view.error)) end
  local snapshot = view.snapshot
  if not snapshot then
    if not view.error then add("Loading timeline…") end
    return rows
  end

  local progress = snapshot.progress or {}
  add(value(snapshot.title))
  add(string.format("Revision %s · %.0f%%", value(snapshot.revision), (progress.fraction or 0) * 100))
  add(string.format("%.1f min remaining", progress.remaining_minutes or 0))
  add("Recorded state, not liveness")

  local children = {}
  for _, task in ipairs(snapshot.tasks or {}) do
    local parent = task.parent_id or ""
    children[parent] = children[parent] or {}
    children[parent][#children[parent] + 1] = task
  end
  local function add_tasks(parent, depth)
    for _, task in ipairs(children[parent] or {}) do
      local indent = string.rep("  ", math.min(depth, 4))
      local task_progress = snapshot.task_progress and snapshot.task_progress[task.id]
      add(indent .. "[" .. value(task.status) .. "] " .. value(task.title))
      add(indent .. "ID: " .. value(task.id))
      if task_progress then
        add(indent .. string.format("Progress: %.0f%%", (task_progress.fraction or 0) * 100))
      end
      add(indent .. "Owner: " .. value(task.owner))
      add(indent .. "Priority: " .. (task.priority ~= nil and ("P" .. value(task.priority)) or "unprioritized"))
      add(indent .. "Weight: " .. value(task.weight) .. " · " .. value(task.mode))
      add(indent .. ("Effort: %s/%s min"):format(value(task.done_minutes), value(task.remaining_minutes)))
      if task.detail and task.detail ~= "" then add(indent .. value(task.detail)) end
      add_tasks(task.id, depth + 1)
    end
  end
  local function section(name, entries, emit)
    add("")
    add(name)
    if not entries or #entries == 0 then add("None"); return end
    for _, entry in ipairs(entries) do emit(entry) end
  end

  add("")
  add("Tasks")
  if not snapshot.tasks or #snapshot.tasks == 0 then add("None") end
  add_tasks("", 0)

  section("Reports", snapshot.reports, function(report)
    add(value(report.id) .. " · " .. value(report.author))
    add(report.task_id and ("Task: " .. value(report.task_id)) or "Project")
    add(value(report.summary))
    add(value(report.period_start) .. " – " .. value(report.period_end))
    add("Events: " .. table.concat(report.event_sequences or {}, ", "))
    if report.uncertainty then add("Uncertainty: " .. value(report.uncertainty)) end
    if report.user_action then add("User action: " .. value(report.user_action)) end
  end)
  section("Discussion", snapshot.discussions, function(entry)
    add(value(entry.author) .. " → " .. value(entry.target_type) .. ":" .. value(entry.target_id))
    add(value(entry.text))
  end)
  section("Cooperative controls", snapshot.controls, function(control)
    add(value(control.id) .. " " .. value(control.action) .. " → " .. value(control.owner))
    add("[" .. value(control.status) .. "] " .. value(control.result))
  end)
  section("Recorded events", snapshot.events, function(event)
    add(value(event.sequence) .. " " .. value(event.at))
    add(value(event.kind) .. " " .. value(event.source) .. ":" .. value(event.event_id))
    add("Payload: " .. vim.json.encode(event.payload))
  end)
  return rows
end

return M
