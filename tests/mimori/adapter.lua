local root, temp = assert(vim.env.MIMORI_TEST_ROOT), assert(vim.env.MIMORI_TEST_TMP)
package.path = vim.env.MIMORI_KOMADO .. '/lua/?.lua;' .. vim.env.MIMORI_KOMADO .. '/lua/?/init.lua;' .. root .. '/v2/lua/?.lua;' .. package.path
local c, a, k = require('mimori.client'), require('mimori.komado'), require('komado')
local function wait(f) assert(vim.wait(2500, f, 5), 'timed out') end
local function calls() return #vim.fn.readfile(temp .. '/calls') end
vim.fn.writefile({}, temp .. '/calls'); vim.fn.writefile({'full'}, temp .. '/mode')
c.setup({binary=root..'/tests/mimori/fake-cli.py',state_dir=temp, interval=80, timeout=400})
local component = a.setup({cap=10})
k.setup({root={component},window={position='left',size=40}})
vim.wait(200); assert(calls()==0, 'initially hidden polls')
local redraws=0
vim.api.nvim_create_autocmd('User',{pattern='KomadoRenderPost',callback=function() redraws=redraws+1 end})
k.open(); wait(function() return c.snapshot().status=='connected' end)
assert(a.visible())
local rootrow = c.snapshot().data.roots[1]
wait(function() return table.concat(vim.api.nvim_buf_get_lines(k.get_state().bufnr,0,-1,false),'\n'):find('W2+?',1,true) end)
vim.fn.writefile({'unchanged'},temp..'/mode')
vim.wait(100); local before=redraws; vim.wait(200); assert(redraws==before,'unchanged redraw')
k.close({keep_buffer=true}); vim.wait(70); local hidden=calls(); vim.wait(200); assert(calls()==hidden,'retained buffer polls')
k.open(); wait(function() return c.snapshot().status=='connected' end)
vim.api.nvim_win_close(k.get_state().winid,true); vim.wait(70); hidden=calls(); vim.wait(200); assert(calls()==hidden,'ordinary close polls')
k.close(); a.open_all(); wait(function() return c.snapshot().status=='connected' end)
local alltab=vim.api.nvim_get_current_tabpage()
vim.cmd('tabnew'); vim.wait(70); hidden=calls(); vim.wait(200); assert(calls()==hidden,'hidden all view polls')
vim.api.nvim_set_current_tabpage(alltab); wait(function() return calls()>hidden end)
vim.fn.writefile({'delay'},temp..'/mode')
a.open_detail(rootrow); local detailtab=vim.api.nvim_get_current_tabpage(); vim.wait(15)
vim.cmd('tabnew'); vim.wait(40); vim.api.nvim_set_current_tabpage(detailtab)
wait(function() return table.concat(vim.api.nvim_buf_get_lines(0,0,-1,false),'\n'):find('liveness: unknown',1,true) end)
a.open_status(); wait(function() return table.concat(vim.api.nvim_buf_get_lines(0,0,-1,false),'\n'):find('Connection: connected',1,true) end)
local statustab=vim.api.nvim_get_current_tabpage()
vim.cmd('tabnew'); vim.wait(70); hidden=calls(); vim.wait(200); assert(calls()==hidden,'hidden status view polls')
vim.api.nvim_set_current_tabpage(statustab); wait(function() return calls()>hidden end)
a.shutdown(); vim.wait(70); hidden=calls(); vim.wait(200); assert(calls()==hidden,'adapter shutdown polls')
local many={}
for i=1,14 do many[i]=vim.deepcopy(rootrow); many[i].session_id='root'..i end
local loose=vim.deepcopy(rootrow); loose.provider='codex'; loose.classification='unresolved'
local rows=a.rows({status='connected',data={roots=many,unclassified={loose}}},10)
local counts={sessions=0,more=0}
for _,row in ipairs(rows) do
  if row.session then counts.sessions=counts.sessions+1 end
  if row.kind=='more' then counts.more=counts.more+1; assert(row.text:find('+5 more',1,true)); assert(row.text:find('wait 5',1,true)) end
end
assert(counts.sessions==10 and counts.more==1)
assert(rows[#rows].session.provider=='codex','provider budget starvation')
assert(rows[#rows].text:find(' ~ ',1,true),'hierarchy uncertainty hidden')
assert(#a.rows({status='connected',data={roots=many,unclassified={loose}}})==17)
assert(not a.clean('\27[31mfoo\nbar\27[0m',30):find('[%c]'))
assert(vim.fn.strdisplaywidth(a.clean('日本語日本語',7))<=7)
local unknown=vim.deepcopy(rootrow); unknown.aggregate_state='future-state'
assert(a.rows({status='connected',data={roots={unknown},unclassified={}}})[2].text:find('? W',1,true))
local fail_system=vim.system; vim.system=function() error('I/O from renderer') end
a.rows(c.snapshot(),10); c.snapshot(); vim.system=fail_system
c.shutdown(); print('adapter: passed; redraws='..redraws..'; visible/hidden visibility verified')
