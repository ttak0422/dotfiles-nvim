-- Exercise package loading through requires, without invoking its command proxy.
return function(Runtime, plan, root, check)
  -- Test-only reset of the previous package fixture, not runtime hot reload.
  vim.api.nvim_del_user_command("PocPick")
  local dependency_plan = { features = {} }
  for _, spec in ipairs(plan.features) do
    if spec.id ~= "metrics" then dependency_plan.features[#dependency_plan.features + 1] = vim.deepcopy(spec) end
  end
  local consumer = vim.deepcopy(dependency_plan.features[1])
  consumer.id = "consumer"
  consumer.requires = { "picker" }
  dependency_plan.features[#dependency_plan.features + 1] = consumer
  local runtime = Runtime.new(dependency_plan, root)
  check(runtime.features.picker.status == "ready" and runtime.features.consumer.status == "ready",
    "startup consumer activates its command-feature dependency")
  vim.cmd("PocPick dependency_path")
  check(_G.poc_last_command.args == "dependency_path", "dependency path registers the real command")
  runtime:close()
  check(vim.api.nvim_get_commands({ builtin = false }).PocPick ~= nil,
    "cleanup must preserve a real command loaded through requires")
  vim.cmd("PocPick after_cleanup")
  check(_G.poc_last_command.args == "after_cleanup", "real command remains callable after cleanup")
end
