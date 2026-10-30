return function(Manager, definition, check, drain)
  local api = vim.api
  local manager = Manager.new({ interval = 60000 })
  local facade = manager.facade
  check(manager:swap(definition("v1", 1)).status == "committed", "initial generation")
  local captured = manager.current.service.read
  local old = manager.current
  vim.cmd("PocGeneration")
  local old_reply = old.service.request()
  manager:queue("on_event") -- queued before commit: must not reach either generation
  check(manager:swap(definition("v2", 2)).status == "committed", "v1 to v2 commit")
  check(manager:snapshot().version == 2 and manager:snapshot().data.total == 1, "versioned value migration")
  check(captured() == "v1" and facade.read() == "v2", "old closure survives while facade dispatches new generation")
  old_reply("stale reply after commit")
  drain()
  check(manager:snapshot().data.events == 0 and old.service.state.events == 0, "queued old event is suppressed")
  check(manager:snapshot().data.last == "none" and old.service.state.last == "none", "late old async reply is suppressed")
  local reply = manager.current.service.request()
  reply("active reply"); drain()
  check(manager:snapshot().data.last == "active reply", "current async reply works")

  for i = 3, 22 do
    check(manager:swap(definition("v" .. i, i % 2 == 0 and 2 or 1)).status == "committed", "repeated commit " .. i)
    check(#api.nvim_get_autocmds({ group = manager.group }) == 2, "no duplicate autocmd registrations " .. i)
    check(api.nvim_get_commands({ builtin = false }).PocGeneration ~= nil, "stable command registration " .. i)
  end
  vim.cmd("PocGeneration")
  check(manager:snapshot().data.total == 2, "stable command reaches current generation exactly once")
  check(facade.read() == "v22", "same facade follows all repeated generations")
  api.nvim_exec_autocmds("User", { pattern = "PocGenerationEvent" })
  api.nvim_exec_autocmds("User", { pattern = "PocGenerationOwned" })
  drain()
  check(manager:snapshot().data.events == 1 and manager:snapshot().data.owned_events == 1, "each event dispatches once")

  local previous = manager.current
  local before = manager:snapshot()
  local pending_reply = previous.service.request()
  local failed = manager:swap(definition("bad", 1, { failActivation = true }))
  check(failed.status == "retainedPrevious" and manager.current == previous, "activation failure retains old generation")
  check(vim.deep_equal(before, manager:snapshot()), "activation failure preserves old plain state")
  check(#api.nvim_get_autocmds({ group = manager.group }) == 2, "failed candidate registrations cleaned")
  check(facade.run() == "v22", "old facade resumes after failed activation")
  pending_reply("request started before quiesce"); drain()
  check(manager:snapshot().data.last == "active reply", "pre-quiesce reply remains invalid after retaining old generation")
  api.nvim_exec_autocmds("User", { pattern = "PocGenerationOwned" })
  drain()
  check(manager:snapshot().data.owned_events == 2, "old owned event gate resumes after failed activation")
  previous.service.request()("resumed reply"); drain()
  check(manager:snapshot().data.last == "resumed reply", "fresh async request works after retained generation resumes")
  check(manager:swap(definition("migration-failure", 1, { failMigration = true })).status == "retainedPrevious",
    "migration failure retains previous generation")
  local snapshot = manager:snapshot()
  snapshot.data.total = -10
  check(manager:snapshot().data.total ~= -10, "snapshot does not alias active state")
  local invalid = definition("invalid", 2)
  invalid.initial.bad = function() end
  check(manager:swap(invalid).status == "rejected" and manager.current == previous,
    "non-data initial state rejected without replacing active generation")
  invalid.initial.bad = invalid.initial
  check(manager:swap(invalid).status == "rejected", "cyclic state rejected")

  local last = manager.current
  manager:queue("on_event")
  last.service.request()("reply queued before shutdown")
  check(manager:close(), "owned cleanup succeeds")
  manager:close()
  drain()
  check(last.service.state.last == "resumed reply", "queued callback invalid after shutdown")
  check(api.nvim_get_commands({ builtin = false }).PocGeneration == nil, "owned command removed")
  check(#api.nvim_get_autocmds({ event = "User", pattern = "PocGenerationOwned" }) == 0, "owned autocmds removed")
  check(manager.timer:is_closing(), "timer closed at shutdown")
  check(not pcall(facade.run), "facade fails closed after shutdown")

  local unsafe = Manager.new({ interval = 60000 })
  unsafe:swap(definition("old", 1))
  local outcome = unsafe:swap(definition("bad", 1, { failActivation = true, failCleanup = true }))
  check(outcome.status == "restartRequired" and unsafe.phase == "restartRequired", "candidate cleanup failure requires restart")
  check(not pcall(unsafe.facade.run), "restart-required state blocks dispatch")
  unsafe:close()

  local retire = Manager.new({ interval = 60000 })
  retire:swap(definition("old", 1, { failCleanup = true }))
  check(retire:swap(definition("new", 2)).status == "restartRequired", "old cleanup failure after commit requires restart")
  check(not pcall(retire.facade.run), "partial commit is not reported as a successful rollback")
  retire:close()
end
