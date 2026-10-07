-- Ordering/budget tests: no collector, filesystem or provider state is used.
local root = assert(vim.env.MIMORI_TEST_ROOT)
package.path = root .. '/v2/lua/?.lua;' .. package.path
local a = require('mimori.komado')
local function session(provider, id, state, extra)
  return vim.tbl_extend('force', {
    provider = provider, session_id = id, state = state, aggregate_state = state,
    classification = 'resolved', running_descendants = 0, unresolved_requests = 0,
    unresolved_count_exact = true, attention_unknown = false, liveness = 'unknown',
  }, extra or {})
end
local function snapshot(roots, loose)
  return { status = 'connected', data = { roots = roots or {}, unclassified = loose or {} } }
end
local function ids(rows)
  local result = {}
  for _, row in ipairs(rows) do
    if row.session then result[#result + 1] = row.session.provider .. '/' .. row.session.session_id end
  end
  return result
end
local function equal(actual, expected) assert(vim.deep_equal(actual, expected), vim.inspect({actual, expected})) end
local history, work = {}, {}
for i = 1, 12 do history[i] = session('claude', string.format('a-ended-%02d', i), 'ended') end
for i = 1, 6 do work[i] = session('codex', string.format('z-work-%02d', i), 'running') end
local mixed = snapshot(vim.list_extend(vim.deepcopy(history), work))
local unchanged = vim.deepcopy(mixed)
local chosen = ids(a.rows(mixed, 10))
assert(#chosen == 10)
for i = 1, 4 do assert(chosen[i] == 'claude/a-ended-0' .. i) end
for i = 1, 6 do assert(chosen[i + 4] == 'codex/z-work-0' .. i, 'history starved active provider') end
equal(mixed, unchanged) -- sorting never mutates the shared client snapshot

-- A single slot belongs to the active provider, even if its group comes later.
equal(ids(a.rows(mixed, 1)), { 'codex/z-work-01' })
local overflow
for _, row in ipairs(a.rows(mixed, 1)) do
  if row.kind == 'more' and row.text:find('+12 more', 1, true) then overflow = row.text end
end
assert(overflow and overflow:find('wait 0', 1, true), 'ended overflow counts changed')

-- Each provider keeps stable ID order within the non-ended/ended partitions.
local shared = snapshot({ session('claude', 'a-ended', 'ended'), session('claude', 'z-idle', 'idle'),
  session('claude', 'y-unknown', 'unknown'), session('codex', 'a-ended', 'ended') },
  { session('codex', 'z-loose', 'running', { classification = 'unclassified' }) })
equal(ids(a.rows(shared)), { 'claude/y-unknown', 'claude/z-idle', 'claude/a-ended', 'codex/z-loose', 'codex/a-ended' })
equal(ids(a.rows(shared, 3)), { 'claude/y-unknown', 'claude/z-idle', 'codex/z-loose' })
assert(a.rows(shared)[6].text:find(' ~ ', 1, true), 'unclassified hierarchy marker lost')

-- An ended parent with running/waiting/unknown descendants is still prioritized.
-- Defensive count/quality checks also retain contradictory future responses.
local keep = {
  { state = 'idle', aggregate_state = 'idle' },
  { state = 'unknown', aggregate_state = 'unknown' },
  { state = 'future', aggregate_state = 'future' },
  { aggregate_state = 'running', running_descendants = 2 },
  { aggregate_state = 'waiting', unresolved_requests = 1 },
  { aggregate_state = 'unknown' },
  { aggregate_state = 'future' },
  { running_descendants = 1 },
  { unresolved_requests = 1 },
  { unresolved_count_exact = false },
  { attention_unknown = true },
  { state = 'idle', aggregate_state = 'ended' },
  { state = 'running', aggregate_state = 'ended' },
}
for _, fields in ipairs(keep) do
  for _, collection in ipairs({ 'roots', 'unclassified' }) do
    local s = snapshot({ session('claude', 'a-ended', 'ended') })
    s.data[collection][#s.data[collection] + 1] = session('claude', 'z-keep', 'ended', fields)
    equal(ids(a.rows(s, 1)), { 'claude/z-keep' })
  end
end
-- Liveness and old timestamps alone never turn idle/unknown into an end.
for _, state in ipairs({ 'idle', 'unknown' }) do
  local row = session('claude', 'z-old', state, { liveness = 'ended', last_event_at = '2000-01-01T00:00:00Z' })
  equal(ids(a.rows(snapshot({ history[1], row }), 1)), { 'claude/z-old' })
end

-- Both passes share one cap and preserve fairness among equally ranked groups.
local balanced = snapshot({ session('claude', 'a-ended', 'ended'), session('codex', 'a-ended', 'ended'),
  session('demo', 'a-ended', 'ended'), session('claude', 'z-live', 'idle'), session('codex', 'z-live', 'unknown'),
  session('demo', 'z-live', 'waiting', { unresolved_requests = 2 }) })
equal(ids(a.rows(balanced, 2)), { 'claude/z-live', 'codex/z-live' })
equal(ids(a.rows(balanced, 4)), { 'claude/z-live', 'claude/a-ended', 'codex/z-live', 'demo/z-live' })
for cap = 1, 20 do
  local result = ids(a.rows(balanced, cap))
  assert(#result == math.min(cap, 6), 'shared cap exceeded/underused')
  if cap <= 3 then for _, id in ipairs(result) do assert(not id:find('a-ended', 1, true)) end end
end
local rows = a.rows(balanced, 1)
assert(rows[#rows].text:find('+2 more · wait 1', 1, true), 'hidden attention count lost')
equal(ids(a.rows(snapshot(history), 2)), { 'claude/a-ended-01', 'claude/a-ended-02' })
assert(#ids(a.rows(snapshot(history))) == 12, 'all view dropped ended history')

-- Repeated backend ordering changes do not jitter either partition.
local expected = a.rows(balanced)
math.randomseed(13)
for _ = 1, 30 do
  for i = #balanced.data.roots, 2, -1 do
    local j = math.random(i)
    balanced.data.roots[i], balanced.data.roots[j] = balanced.data.roots[j], balanced.data.roots[i]
  end
  equal(a.rows(balanced), expected)
end
if vim.env.MIMORI_PRIORITY_SNAPSHOT then
  local data = vim.json.decode(table.concat(vim.fn.readfile(vim.env.MIMORI_PRIORITY_SNAPSHOT), '\n'))
  local live = { status = 'connected', data = { roots = data.roots or {}, unclassified = data.unclassified or {} } }
  equal(ids(a.rows(live, 6)), { 'codex/parent-attention', 'codex/parent-running', 'codex/parent-unknown',
    'codex/parent-waiting', 'codex/standalone-idle', 'codex/standalone-unknown' })
  local all = ids(a.rows(live))
  assert(#all == 8 and all[7] == 'codex/parent-ended' and all[8] == 'codex/parent-idle',
    'backend ended/idle-child summaries must remain available in all view')
end
print('priority: passed; cross-provider cap, root/unclassified safety, uncertainty, stable order and history retention verified')
