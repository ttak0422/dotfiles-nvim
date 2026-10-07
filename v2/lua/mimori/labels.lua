-- Display-only metadata. No filesystem, Git, provider or transcript access.
local M = {}

local function sanitize(value)
  local text = type(value) == "string" and value or ""
  text = text:gsub("\27%[[0-?]*[ -/]*[@-~]", ""):gsub("\27%][^\7]*\7", "")
  return text:gsub("[%c]", " "):gsub("\194[\128-\159]", " ")
    :gsub("\226\128[\168-\174]", " "):gsub("\226\129[\166-\169]", " ")
end

-- Keep combining characters, emoji modifiers, flags and ZWJ sequences together.
-- Width is still measured by Neovim, including the user's ambiwidth setting.
local function clusters(text)
  local result, join, regional = {}, false, false
  for _, char in ipairs(vim.fn.split(text, "\\zs")) do
    local code = vim.fn.char2nr(char)
    local flag = code >= 0x1f1e6 and code <= 0x1f1ff and vim.fn.strchars(char) == 1
    local modifier = (code >= 0x1f3fb and code <= 0x1f3ff) or (code >= 0xfe00 and code <= 0xfe0f)
    if #result > 0 and (join or code == 0x200d or modifier or vim.fn.strdisplaywidth(char) == 0 or (flag and regional)) then
      result[#result] = result[#result] .. char
    else
      result[#result + 1] = char
    end
    join = code == 0x200d
    regional = flag and not regional
  end
  return result
end

function M.clean(value, width)
  local text = sanitize(value == nil and "?" or tostring(value))
  width = math.max(0, width or 120)
  if vim.fn.strdisplaywidth(text) <= width then return text end
  if width == 0 then return "" end
  local ellipsis = vim.fn.strdisplaywidth("…") <= width and "…" or "."
  local result = ""
  for _, char in ipairs(clusters(text)) do
    if vim.fn.strdisplaywidth(result .. char .. ellipsis) > width then break end
    result = result .. char
  end
  return result .. ellipsis
end

local function nonempty(value)
  local text = vim.trim(sanitize(value))
  return text ~= "" and text or nil
end

function M.describe(row)
  local task, cwd = nonempty(row.name), nonempty(row.cwd)
  local project = cwd and (cwd:gsub("/+$", ""):match("([^/]+)$") or "/")
  return { task = task, cwd = cwd, project = project,
    primary = task or project or "名前なし", source = task and "name" or (project and "cwd" or "missing") }
end

local function parts(info, width)
  if not info.task or not info.project or info.task == info.project then return M.clean(info.primary, width) end
  local separator = " · "
  local full = info.task .. separator .. info.project
  if vim.fn.strdisplaywidth(full) <= width then return full end
  local available = width - vim.fn.strdisplaywidth(separator)
  if available < 10 then return M.clean(info.task, width) end
  local project_width = math.min(vim.fn.strdisplaywidth(info.project), math.max(3, math.floor(available / 3)))
  return M.clean(info.task, available - project_width) .. separator .. M.clean(info.project, project_width)
end

local function mark_collisions(infos, key)
  local groups, changed = {}, false
  for i, info in ipairs(infos) do
    local value = key(info, i)
    groups[value] = groups[value] or {}; table.insert(groups[value], info)
  end
  for _, group in pairs(groups) do
    if #group > 1 then
      for _, info in ipairs(group) do
        if not info.needs_id then info.needs_id = true; changed = true end
      end
    end
  end
  return changed
end

local function short_ids(entries)
  local sources, sizes, fingerprints = {}, {}, {}
  local function fingerprint(i)
    sources[i] = vim.fn.sha256(entries[i].session_id)
    sizes[i], fingerprints[i] = 4, true
  end
  for i, row in ipairs(entries) do
    -- IDs stay opaque. Start at their ASCII tail; unusual IDs get an explicitly
    -- marked fingerprint so controls/UTF-8 fragments never become a label.
    if row.session_id:match("^[%w_-]+$") then sources[i], sizes[i] = row.session_id, 4
    else fingerprint(i) end
  end
  while true do
    local groups, changed = {}, false
    for i, source in ipairs(sources) do
      local short = (fingerprints[i] and "~" or "") .. source:sub(-sizes[i])
      groups[short] = groups[short] or {}; table.insert(groups[short], i)
    end
    for _, group in pairs(groups) do
      if #group > 1 then
        for _, i in ipairs(group) do
          -- Very long common tails must not consume the whole narrow row.
          if not fingerprints[i] and (sizes[i] >= 8 or sizes[i] >= #sources[i]) then fingerprint(i)
          else sizes[i] = sizes[i] + 2 end
          changed = true
        end
      end
    end
    if not changed then break end
  end
  local result = {}
  for i, source in ipairs(sources) do result[i] = (fingerprints[i] and "~" or "") .. source:sub(-sizes[i]) end
  return result
end

local function render(info, width)
  if not info.needs_id then return parts(info, width) end
  local suffix = " #" .. info.short_id
  local available = width - vim.fn.strdisplaywidth(suffix)
  if available <= 0 then return M.clean("#" .. info.short_id, width) end
  return parts(info, available) .. suffix
end

-- Called before applying the row cap, so hidden sessions still disambiguate names.
-- Return fresh display objects; never annotate or mutate the client's snapshot.
function M.prepare(entries, widths)
  local infos, shorts = {}, short_ids(entries)
  for i, row in ipairs(entries) do
    infos[i] = M.describe(row)
    infos[i].short_id = shorts[i]
    infos[i].needs_id = infos[i].source == "missing"
  end
  mark_collisions(infos, function(info) return info.primary end)
  -- Different full names can become identical after cell-width truncation.
  -- IDs only get added; the pass terminates after at most #entries changes.
  while mark_collisions(infos, function(info, i) return render(info, widths[i]) end) do end
  for i, info in ipairs(infos) do info.text = render(info, widths[i]) end
  return infos
end

return M
