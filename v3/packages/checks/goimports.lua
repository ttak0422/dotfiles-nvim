for _, command in ipairs({ "goimports", "gofumpt", "staticcheck" }) do
  assert(vim.fn.executable(command) == 1, command .. " is missing from the profile")
end

-- The real configured none-ls source must add imports, not merely run gofmt.
require("null-ls")
local methods = require("null-ls.methods").internal
local available = require("null-ls.sources").get_available("go", methods.FORMATTING)
assert(
  vim.iter(available):any(function(source)
    return source.name == "goimports"
  end),
  "goimports is not registered for Go formatting"
)
local diagnostics = require("null-ls.sources").get_available("go", methods.DIAGNOSTICS_ON_SAVE)
assert(
  vim.iter(diagnostics):any(function(source)
    return source.name == "staticcheck"
  end),
  "staticcheck diagnostics must remain configured"
)

local root = vim.fn.tempname()
vim.fn.mkdir(root .. "/.git", "p")
vim.fn.writefile({ "module example.com/goimports-check", "", "go 1.25" }, root .. "/go.mod")
local path = root .. "/main.go"
vim.fn.writefile({ "package main", "", "func main(){", 'fmt.Println("hello")', "}" }, path)
vim.cmd.edit(vim.fn.fnameescape(path))
local buf = vim.api.nvim_get_current_buf()
assert(vim.bo.filetype == "go")
assert(
  vim.wait(15000, function()
    return #vim.lsp.get_clients({ name = "null-ls", bufnr = buf }) > 0
  end, 50),
  "none-ls did not attach to Go"
)
vim.lsp.buf.format({ bufnr = buf, name = "null-ls", timeout_ms = 15000 })
local expected = {
  "package main",
  "",
  'import "fmt"',
  "",
  "func main() {",
  '\tfmt.Println("hello")',
  "}",
}
local actual = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
assert(vim.deep_equal(actual, expected), "Go formatting failed: " .. vim.inspect(actual))
vim.lsp.buf.format({ bufnr = buf, name = "null-ls", timeout_ms = 15000 })
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 0, -1, false), expected), "Go formatting must be idempotent")
vim.cmd("checkhealth null-ls")
local health = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
for _, command in ipairs({ "goimports", "gofumpt", "staticcheck" }) do
  assert(health:find(command .. ': the command "' .. command .. '" is executable.', 1, true), health)
end
assert(vim.v.errmsg == "", vim.v.errmsg)
