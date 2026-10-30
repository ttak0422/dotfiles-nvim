local api = vim.api
local root = assert(vim.env.POC_ROOT)
local plan = dofile(assert(vim.env.POC_PLAN))
local Runtime = dofile(root .. "/runtime.lua")
local checks = 0
local function check(condition, message)
  assert(condition, message)
  checks = checks + 1
end
local function drain() vim.wait(30, function() return false end, 1) end
local function event(name, buf) api.nvim_exec_autocmds(name, { buffer = buf }) end
local function markdown()
  local buf = api.nvim_create_buf(true, false)
  vim.bo[buf].filetype = "markdown"
  return buf
end

local function run()
  vim.opt.packpath = root .. "/fixtures"
  local existing = markdown()
  local runtime = Runtime.new(plan, root)
  check(runtime.features.base.status == "ready", "startup fixture")
  check(runtime.features.picker.status == "registered", "command plugin must stay lazy")
  local ctx = dofile(root .. "/features/metrics/tests.lua")(runtime, existing, check)

  local first = markdown()
  check(runtime.contexts.metrics[first] ~= nil, "first FileType must attach without replay")
  local initial = runtime.requests[#runtime.requests]
  initial.done("first"); drain()
  check(runtime.contexts.metrics[first].state.value == "first", "initial update")
  local current = runtime.contexts.metrics[first]
  check(#current.owned == 2, "completed request leaves no resource ledger entry")

  dofile(root .. "/features/picker/tests.lua")(runtime, first, check)

  event("TextChanged", first)
  local old = runtime.requests[#runtime.requests]
  event("TextChanged", first)
  local latest = runtime.requests[#runtime.requests]
  check(old.cancelled, "superseded request cancellation")
  latest.done("latest"); old.done("old despite cancellation"); drain()
  check(current.state.value == "latest", "out-of-order result rejected")

  event("TextChanged", first)
  local edited = runtime.requests[#runtime.requests]
  api.nvim_buf_set_lines(first, 0, 1, false, { "changed before next update" })
  edited.done("wrong snapshot"); drain()
  check(current.state.value == "latest", "changedtick guard before next request")

  event("TextChanged", first)
  local scheduled = runtime.requests[#runtime.requests]
  scheduled.done("queued before disposal")
  runtime:detach("metrics", first)
  runtime:detach("metrics", first)
  drain()
  check(current.state.value == "latest", "dispose invalidates already scheduled apply")
  check(table.concat(current.state.cleanup, ",") == "second,first", "cleanup once, reverse acquisition order")
  check(#current.owned == 0, "empty resource ledger after dispose")
  local replacement = runtime:attach("metrics", first)
  check(replacement and replacement.generation ~= current.generation, "fresh generation after reattach")

  event("TextChanged", first)
  local after_detach = runtime.requests[#runtime.requests]
  runtime:detach("metrics", first)
  after_detach.done("provider ignored cancellation"); drain()
  check(replacement.state.value == nil, "late callback cannot publish after detach")
  check(runtime.features.base.status == "ready", "buffer cleanup leaves session dependency ready")

  local second = markdown()
  local second_ctx = runtime.contexts.metrics[second]
  api.nvim_buf_set_name(second, root .. "/renamed-fixture.md")
  local renamed_ctx = runtime.contexts.metrics[second]
  check(renamed_ctx and not second_ctx.alive and renamed_ctx ~= second_ctx, "rename closes old scope and catches up")
  vim.bo[second].filetype = "text"
  check(runtime.contexts.metrics[second] == nil, "filetype mismatch detaches")

  local buffer_count = 0
  for _ in pairs(runtime.contexts.metrics) do buffer_count = buffer_count + 1 end
  api.nvim_set_current_buf(existing)
  vim.cmd("vsplit")
  local count_after = 0
  for _ in pairs(runtime.contexts.metrics) do count_after = count_after + 1 end
  check(buffer_count == count_after, "two windows share one buffer scope")
  api.nvim_buf_delete(existing, { force = true })
  check(runtime.contexts.metrics[existing] == nil and not ctx.alive, "buffer deletion disposes scope")
  check(#runtime.errors == 0, "no unexpected lifecycle errors")
  runtime:close()
  dofile(root .. "/features/picker/dependency-test.lua")(Runtime, plan, root, check)

  -- Failed setup prevents dependents, cleans acquired resources, preserves independent startup.
  local bad_plan = vim.deepcopy(plan)
  for _, f in ipairs(bad_plan.features) do
    f.package = vim.NIL
    if f.id == "picker" then f.activation = { kind = "dependency" }; f.requires = { "base" } end
    if f.id == "base" then f.options.failSetup = true end
  end
  local independent = vim.deepcopy(bad_plan.features[1])
  independent.id = "independent"
  independent.options = {}
  bad_plan.features[#bad_plan.features + 1] = independent
  local bad = Runtime.new(bad_plan, root)
  check(not bad:ensure("picker") and bad.features.picker.status == "blocked", "dependency failure blocks setup")
  check(bad.features.base.session.state.cleaned, "partial setup resources released")
  check(bad.features.independent.status == "ready", "independent startup survives another setup failure")
  check(#bad.errors >= 2, "failure diagnostics recorded")
  bad:close()
  print("PASS: " .. checks .. " runtime lifecycle checks")
end

local ok, err = xpcall(run, debug.traceback)
if not ok then io.stderr:write(err .. "\n"); vim.cmd("cquit 1") end
vim.cmd("qa!")
