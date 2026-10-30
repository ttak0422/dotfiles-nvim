-- Feature-local first-invocation contract, called by the integration harness.
return function(runtime, buf, check)
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "a", "b", "c" })
  vim.cmd("silent 1,2PocPick! first second")
  check(_G.poc_last_command.args == "first second" and _G.poc_last_command.bang, "first command args and bang")
  check(_G.poc_last_command.line1 == 1 and _G.poc_last_command.line2 == 2, "first command range")
  check(_G.poc_last_command.smods.silent, "first command modifiers")
  check(table.concat(runtime.trace, ",") == "base.setup,picker.prepare,picker.setup", "dependency/prepare/setup order")
  vim.cmd("PocPick again")
  check(#runtime.trace == 3, "setup executes once")
end
