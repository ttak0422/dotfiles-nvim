-- Feature-local initial-buffer contract, called by the integration harness.
return function(runtime, existing, check)
  local ctx = assert(runtime.contexts.metrics[existing])
  check(#runtime.requests == 1, "existing buffer catch-up and initial update")
  vim.api.nvim_exec_autocmds("FileType", { buffer = existing })
  check(runtime.contexts.metrics[existing] == ctx and #runtime.requests == 1, "no duplicate attach")
  return ctx
end
