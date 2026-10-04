package.path = vim.env.MIMORI_TEST_ROOT .. '/v2/lua/?.lua;' .. package.path
local c = require('mimori.client')
c.setup({binary=vim.env.MIMORI_BIN,state_dir=vim.env.MIMORI_STATE_DIR,interval=100,timeout=1000})
local off=c.subscribe(function() end)
assert(vim.wait(10000,function() return c.snapshot().status=='connected' and c.snapshot().data end,10),vim.inspect(c.snapshot()))
vim.fn.writefile({'ready'},vim.env.MIMORI_CLIENT_MARKER)
assert(vim.wait(20000,function() return vim.fn.filereadable(vim.env.MIMORI_CLIENT_STOP)==1 end,10),'client stop')
off(); c.shutdown()
