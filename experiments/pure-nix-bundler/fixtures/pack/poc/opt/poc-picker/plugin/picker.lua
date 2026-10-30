vim.api.nvim_create_user_command("PocPick", function(command)
  _G.poc_last_command = command
end, { nargs = "*", bang = true, range = true })
