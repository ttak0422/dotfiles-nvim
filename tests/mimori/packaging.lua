-- Exercise the actual module preload declarations without adding v2/lua to
-- package.path. A source-tree-only test can otherwise miss a bundled module.
local root = assert(vim.env.MIMORI_TEST_ROOT)
local config = table.concat(vim.fn.readfile(root .. '/v2/default.nix'), '\n')
local found = {}
for name, path in config:gmatch('package%.preload%["(mimori%.[%w_]+)"%] = function%(%) return dofile%("%${(.-)}"%) end') do
  local file = root .. '/v2/' .. path:gsub('^%./', '')
  found[name] = true
  package.preload[name] = function() return dofile(file) end
end
for _, name in ipairs({'mimori.client', 'mimori.labels', 'mimori.komado'}) do
  assert(found[name], 'module missing from Nix preloads: ' .. name)
  assert(type(require(name)) == 'table', 'bundled module could not load: ' .. name)
end
assert(require('mimori.labels').describe({cwd='/repo/mimori'}).primary == 'mimori')
print('packaging: passed; Nix preloads load all mimori modules without source-tree package.path')
