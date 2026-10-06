local root, temp = assert(vim.env.MIMORI_TEST_ROOT), assert(vim.env.MIMORI_TEST_TMP)
package.path = root .. '/v2/lua/?.lua;' .. package.path
local c = require('mimori.client')
local function wait(f, message) assert(vim.wait(4000, f, 5), message or 'timed out') end
local function mode(name) vim.fn.writefile({ name }, temp .. '/mode') end
local function count(verb)
  local n = 0
  for _, line in ipairs(vim.fn.readfile(temp .. '/calls')) do
    local r = vim.json.decode(line)
    if not verb or r.args[1] == verb then n = n + 1 end
  end
  return n
end
local function setup(extra)
  c.setup(vim.tbl_extend('force', { binary = root .. '/tests/mimori/fake-cli.py', state_dir = temp,
    interval = 80, timeout = 350, ensure_timeout = 1500, max_backoff = 320, max_stdout = 5000, max_stderr = 500 }, extra or {}))
end
vim.fn.writefile({}, temp .. '/calls')
mode('full'); setup()
local callbacks = 0
local off1 = c.subscribe(function() error('isolated subscriber failure') end)
local off2 = c.subscribe(function() callbacks = callbacks + 1 end)
wait(function() return c.snapshot().status == 'connected' end)
assert(c.snapshot().data.roots[1].generation == '18446744073709551615', 'uint64 precision')
local data = c.snapshot().data
mode('unchanged')
local before = callbacks
vim.wait(250)
assert(c.snapshot().data == data and callbacks == before, 'unchanged rebuild/emission')
off1(); off2(); off2()
assert(c.snapshot().status == 'paused')
local calls = count(); vim.wait(250); assert(count() == calls, 'hidden polling')
c.refresh(); wait(function() return count() > calls and c.snapshot().status == 'connected' end)
calls = count(); vim.wait(250); assert(count() == calls, 'manual refresh repeats')
local release = c.subscribe(function() end)
for _, failure in ipairs({'error','malformed','incomplete','version','duplicate','oversized','stderr','missing-field'}) do
  mode(failure); c.refresh()
  wait(function() return c.snapshot().status == 'error' or c.snapshot().status == 'incompatible' end, failure)
  assert(c.snapshot().data == data, 'failed snapshot replacement ' .. failure)
  mode('unchanged'); c.refresh()
  wait(function() return c.snapshot().status == 'connected' end, 'recover ' .. failure)
  assert(c.snapshot().data == data, 'recovery replaced unchanged rows')
end
mode('slow'); c.refresh(); wait(function() return c.snapshot().status=='error' end); assert(c.snapshot().diagnostic:find('timeout',1,true))
release()
mode('empty'); setup(); c.refresh(); wait(function() return c.snapshot().status=='connected' end); assert(#c.snapshot().data.roots==0)
mode('unchanged-bad'); setup(); c.refresh()
wait(function() return c.snapshot().status == 'incompatible' end)
assert(c.snapshot().diagnostic:find('unchanged without matching snapshot', 1, true))
mode('full'); setup(); c.refresh(); wait(function() return c.snapshot().status == 'connected' end)
mode('delay')
local details = 0
local q = count('query')
c.detail('claude','root',function(row) assert(row); details=details+1 end)
c.detail('claude','root',function(row) assert(row); details=details+1 end)
wait(function() return details == 2 end)
assert(count('query') == q + 1, 'detail requests not coalesced')
-- A split detail and a different hover may both be pending. Their releases
-- cancel only their own identity/token, while the shared CLI remains serialized.
local concurrent, retained, removed = {}, false, false
local cancel_shared = c.detail('claude','root',function() removed=true end)
c.detail('claude','root',function(row) retained=row and true end)
c.detail('claude','missing',function(_,err) concurrent.missing=err end)
cancel_shared()
wait(function() return retained and concurrent.missing end)
assert(not removed and concurrent.missing=='NotFound', 'different detail views interfere')
local cancelled_other=false
local cancel_other=c.detail('claude','missing',function() cancelled_other=true end)
local still_pending=false
c.detail('claude','root',function(row) still_pending=row and true end)
cancel_other()
wait(function() return still_pending end)
assert(not cancelled_other,'cancelled identity callback fired')
local cancelled = false
local cancel = c.detail('claude','root',function() cancelled=true end); cancel(); vim.wait(200); assert(not cancelled)
local notfound
c.detail('claude','missing',function(_,err) notfound=err end); wait(function() return notfound end); assert(notfound=='NotFound')
mode('slow'); c.refresh(); vim.wait(30)
c.setup({ binary = '/does/not/exist', state_dir = temp, interval = 80 })
c.refresh(); wait(function() return c.snapshot().status=='missing_binary' end)
assert(c.snapshot().data == nil, 'scope retained old results')
mode('full'); setup({provider='codex'}); c.refresh(); wait(function() return c.snapshot().status=='connected' end)
mode('slow'); local off = c.subscribe(function() end)
vim.wait(40); off(); mode('full'); local reopened = c.subscribe(function() end)
wait(function() return c.snapshot().status=='connected' end)
reopened()
mode('delay'); local demand = c.subscribe(function() end)
for _ = 1, 30 do c.refresh(); c.detail('claude','root',function() end) end
vim.wait(500); demand(); c.shutdown(); c.shutdown(); vim.wait(50)
assert(vim.fn.filereadable(temp .. '/overlap') == 0, 'more than one CLI process')
print('client: passed; callbacks=' .. callbacks .. '; CLI calls=' .. count())
