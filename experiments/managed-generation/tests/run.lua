local root = assert(vim.env.GENERATION_POC_ROOT)
local Manager = dofile(root .. "/manager.lua")
local definition = dofile(root .. "/features/counter/definition.lua")
local checks = 0
local function check(value, message)
  assert(value, message)
  checks = checks + 1
end
local function drain() vim.wait(15, function() return false end, 1) end
local function run()
  dofile(root .. "/features/counter/tests.lua")(Manager, definition, check, drain)
  -- Exercise the real uv timer, not only manually delivered callback fixtures.
  local timer = Manager.new({ interval = 5 })
  timer:swap(definition("timer-v1", 1))
  check(vim.wait(1000, function() return timer:snapshot().data.ticks >= 1 end, 1), "real timer reaches initial generation")
  local old = timer.current
  timer:swap(definition("timer-v2", 2))
  local ticks = timer:snapshot().data.ticks
  check(vim.wait(1000, function() return timer:snapshot().data.ticks > ticks end, 1), "real timer dispatches replacement generation")
  local old_ticks = old.service.state.ticks
  local current = timer.current
  timer:close(); drain()
  check(old.service.state.ticks == old_ticks, "timer never returns to retired generation")
  local stopped_ticks = current.service.state.ticks
  drain()
  check(current.service.state.ticks == stopped_ticks, "timer cannot dispatch after shutdown")
  check(timer.timer:is_closing(), "real timer handle is closed")
  local cleanup, order = Manager.new(), {}
  cleanup:swap({ stateVersion = 1, initial = {}, activate = function(ctx, state)
    ctx:own(function() order[#order + 1] = "first" end)
    ctx:own(function() order[#order + 1] = "second" end)
    return { state = state, run = function() end }
  end })
  cleanup:close()
  check(table.concat(order, ",") == "second,first", "resources disposed in reverse acquisition order")
  print("PASS: " .. checks .. " managed generation checks on " .. tostring(vim.version()))
end
local ok, err = xpcall(run, debug.traceback)
if not ok then io.stderr:write(err .. "\n"); vim.cmd("cquit 1") end
vim.cmd("qa!")
