-- [nfnl] v2/fnl/jdtls.fnl
local function _1_()
  local root_dir = vim.fs.root(0, {"gradlew", "mvnw", ".git"})
  local workspace_dir = (os.getenv("HOME") .. "/.local/share/eclipse/" .. string.gsub(vim.fn.fnamemodify(root_dir, ":p:h"), "/", "_"))
  vim.notify("Starting to delete JDTLS workspace data.")
  os.execute(("rm -rf " .. workspace_dir))
  return vim.notify("JDTLS workspace data deleted.")
end
return vim.api.nvim_create_user_command("JdtDelteteWorkspaceData", _1_, {})
