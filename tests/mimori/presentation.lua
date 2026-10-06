-- Render anonymous snapshots through the pinned Komado DSL, not a mock formatter.
local root = assert(vim.env.MIMORI_TEST_ROOT)
package.path = vim.env.MIMORI_KOMADO .. '/lua/?.lua;' .. vim.env.MIMORI_KOMADO .. '/lua/?/init.lua;' .. root .. '/v2/lua/?.lua;' .. package.path
vim.o.columns = 120; vim.o.lines = 40
local current, subscribers = {status='loading'}, {}
local client = {}
function client.identity(r) return r.provider .. '\0' .. r.session_id end
function client.snapshot() return current end
function client.subscribe(cb)
  local token={}; subscribers[token]=cb; cb(current)
  return function() subscribers[token]=nil end
end
function client.refresh() end
function client.detail(provider,id,cb)
  local cancelled=false
  vim.schedule(function()
    if cancelled then return end
    for _,set in ipairs({current.data.roots,current.data.unclassified}) do
      for _,r in ipairs(set) do if r.provider==provider and r.session_id==id then cb(r); return end end
    end
    cb(nil,'NotFound')
  end)
  return function() cancelled=true end
end
package.loaded['mimori.client']=client
local a=vim.env.MIMORI_BASELINE and dofile(vim.env.MIMORI_BASELINE) or require('mimori.komado')
local k=require('komado')
local function session(provider,id,state,loose)
  return {provider=provider,session_id=id,name=id,generation='1',state=state,aggregate_state=state,
    classification=loose and 'unresolved' or 'resolved',relation=loose and 'unknown' or 'root',
    running_descendants=0,unresolved_requests=0,unresolved_count_exact=true,attention_unknown=false,
    request_ids={},liveness='unknown',ordering='best_effort',last_event_at='2026-10-04T00:00:00Z'}
end
local function snapshot(roots,unclassified,status)
  return {status=status or 'connected',data={roots=roots or {},unclassified=unclassified or {}}}
end
local c=session('claude','review-api-change','idle')
local x=session('codex','implement-provider-layout','running'); x.running_descendants=50
local u=session('codex','12345678-1234-1234-1234-123456789012','waiting',true)
u.unresolved_requests=2; u.unresolved_count_exact=false; u.attention_unknown=true
local overflow={};for i=1,14 do overflow[i]=session(i%2==0 and 'codex' or 'claude',string.format('task-%02d',i),'idle') end
overflow[13].aggregate_state='waiting';overflow[13].unresolved_requests=1
local failed=snapshot({c,x},{u},'error');failed.diagnostic='CLI exit 1: cannot connect to collector'
local cases={
  {'empty',snapshot()}, {'connected-idle',snapshot({c})}, {'populated',snapshot({c,x})},
  {'unknown-wait',snapshot({c},{u})}, {'connecting',{status='loading'}},
  {'disconnected',{status='error',diagnostic='collector socket unavailable'}},
  {'paused',snapshot({c},{},'paused')},
  {'wide-name',snapshot({session('claude','日本語の長いセッション名と進捗確認','running')})},
  {'error-retained',failed}, {'overflow',snapshot(overflow)},
  {'all-states',snapshot({session('claude','a-running','running'),session('claude','b-waiting','waiting'),session('claude','c-idle','idle'),session('claude','d-ended','ended'),session('claude','e-unknown','unknown'),session('claude','f-future','future-state')})},
  {'other-provider',snapshot({session('demo','custom-session','unknown')})},
}
local function publish(s)
  current=s;for _,cb in pairs(subscribers) do cb(s) end
end
local function lines(buf)
  local text=vim.api.nvim_buf_get_lines(buf,0,-1,false)
  for i,line in ipairs(text) do text[i]=line:gsub('%s+$','') end
  while #text>0 and text[#text]=='' do table.remove(text) end
  return text
end
local output={}
for _,width in ipairs({32,40}) do
  a.shutdown();k.close()
  local component=a.setup({cap=10})
  k.setup({root={component},window={position='left',size=width,padding=1}})
  k.open();vim.wait(30)
  for _,case in ipairs(cases) do
    publish(vim.deepcopy(case[2]));k.redraw();vim.wait(20)
    local rendered=lines(k.get_state().bufnr)
    output[#output+1]='## '..case[1]..' / sidebar '..width
    for _,line in ipairs(rendered) do
      assert(vim.fn.strdisplaywidth(line)<=width,'line exceeds sidebar width')
      output[#output+1]=line
    end
    output[#output+1]=''
    if not vim.env.MIMORI_BASELINE then
      local text=table.concat(rendered,'\n')
      assert(not text:find('mimori ·',1,true) and not text:find('classified',1,true))
      assert(text:find('Claude',1,true) and text:find('Codex',1,true))
      if case[1]=='unknown-wait' then assert(text:find('◆ W2+? R0 ~',1,true),'counts or uncertainty truncated') end
      if case[1]=='populated' then assert(text:find('▶ W0 R50',1,true)) end
      if case[1]=='other-provider' then assert(text:find('Other: demo',1,true)) end
    end
  end
end
if not vim.env.MIMORI_BASELINE then
  for _,ambiwidth in ipairs({'single','double'}) do
    vim.o.ambiwidth=ambiwidth
    for _,status in ipairs({'connected','loading','paused','error','missing_binary','incompatible'}) do
      assert(vim.fn.strdisplaywidth(a.status_icon(status))==1)
    end
    for _,state in ipairs({'running','waiting','idle','ended','unknown','future-state'}) do
      assert(vim.fn.strdisplaywidth(a.state_icon(state))==1)
    end
  end
  vim.o.ambiwidth='single'
  local colors={running=0x10aa20,waiting=0xffaa00,idle=0x808080,ended=0x606060,unknown=0x3388ff}
  local links={running='DiagnosticOk',waiting='DiagnosticWarn',idle='Comment',ended='NonText',unknown='DiagnosticInfo'}
  local symbols={}
  for state,color in pairs(colors) do
    vim.api.nvim_set_hl(0,links[state],{fg=color})
    symbols[#symbols+1]=session('claude',state,state)
  end
  local function check_colors(buf,sidebar)
    local marks=vim.api.nvim_buf_get_extmarks(buf,-1,0,-1,{details=true})
    local text=vim.api.nvim_buf_get_lines(buf,0,-1,false)
    for state,color in pairs(colors) do
      local icon=a.state_icon(state)
      local found=false
      for _,mark in ipairs(marks) do
        local line=text[mark[2]+1]
        local d=mark[4]
        if line:find(state,1,true) and d.hl_group and line:sub(mark[3]+1,(d.end_col or 0))==icon then
          assert(vim.api.nvim_get_hl(0,{name=d.hl_group,link=false}).fg==color,'wrong '..state..' color')
          assert(mark[3]==(sidebar and 1 or 0),'state highlight spills into name/counts')
          found=true
        end
      end
      assert(found,'missing '..state..' icon highlight')
    end
  end
  publish(snapshot(symbols));vim.api.nvim_exec_autocmds('ColorScheme',{pattern='mimori-test'});k.redraw();vim.wait(30)
  check_colors(k.get_state().bufnr,true)
  a.open_all();vim.wait(30);check_colors(vim.api.nvim_get_current_buf(),false)
  -- ColorScheme can fire before scheduled cleanup after the all-view window closes.
  vim.api.nvim_win_close(vim.api.nvim_get_current_win(),true)
  vim.api.nvim_exec_autocmds('ColorScheme',{pattern='mimori-closed-view'})
  vim.wait(30)
  -- A user-defined group survives setup and ColorScheme default linking.
  vim.api.nvim_set_hl(0,'MimoriRunning',{fg=0xabcdef})
  vim.api.nvim_exec_autocmds('ColorScheme',{pattern='mimori-custom'})
  assert(vim.api.nvim_get_hl(0,{name='MimoriRunning',link=false}).fg==0xabcdef)
  -- A manually squeezed sidebar still emits valid UTF-8, even when its one
  -- content cell is consumed by an ASCII state/fallback glyph.
  local sidebar=k.get_state()
  for _,ambiwidth in ipairs({'single','double'}) do
    vim.o.ambiwidth=ambiwidth
    for _,width in ipairs({3,4,5}) do
      vim.api.nvim_win_set_width(sidebar.winid,width)
      publish(snapshot(symbols));k.redraw();vim.wait(20)
      for _,line in ipairs(lines(sidebar.bufnr)) do
        assert(vim.fn.strdisplaywidth(line)<=width,'narrow sidebar exceeds display width')
        assert(not line:find('<80>',1,true),'UTF-8 ellipsis split')
      end
      assert(vim.fn.strdisplaywidth(a.clean('long value',1))<=1,'wide ellipsis overflow')
    end
  end
  vim.o.ambiwidth='single';vim.api.nvim_win_set_width(sidebar.winid,40)
  assert(u.classification=='unresolved' and u.relation=='unknown','presentation invented hierarchy')
  -- Full view preserves provider+ID selection when groups grow or input reorders.
  publish(snapshot({c,x},{u}));a.open_all();vim.wait(30)
  local buf=vim.api.nvim_get_current_buf();local win=vim.api.nvim_get_current_win()
  local target
  for i,line in ipairs(lines(buf)) do if line:find('◆ W2+? R0 ~',1,true) then target=i end end
  assert(target);vim.api.nvim_win_set_cursor(win,{target,0})
  publish(snapshot({x,session('claude','aaa-new','idle'),c},{u}));vim.wait(30)
  assert(vim.api.nvim_get_current_line():find('◆ W2+? R0 ~',1,true),'selection changed identity')
  a.open_detail(u);vim.wait(30)
  assert(table.concat(lines(0),'\n'):find('classification: unresolved',1,true))
  publish(failed);a.open_status();vim.wait(30)
  local status=table.concat(lines(0),'\n')
  assert(status:find('Connection: error',1,true) and status:find('retained snapshot',1,true))
  assert(status:find('cannot connect to collector',1,true),'full diagnostic lost')
  local historical=snapshot({c});historical.collector_diagnostic={observed_at='2026-10-04T00:00:00Z',message='synthetic quarantine diagnostic'}
  publish(historical);vim.wait(30)
  status=table.concat(lines(0),'\n')
  assert(status:find('Connection: connected',1,true) and status:find('Historical collector error:',1,true))
  assert(status:find('synthetic quarantine diagnostic',1,true),'collector diagnostic lost')
  a.shutdown();k.close();vim.wait(30)
  assert(next(subscribers)==nil,'view subscription leaked')
else
  a.shutdown();k.close()
end
local destination=vim.env.MIMORI_SNAPSHOT_OUT
if destination then vim.fn.writefile(output,destination) end
print('presentation: rendered '..#cases..' cases at 32/40 columns; '..(vim.env.MIMORI_BASELINE and 'baseline buffers captured' or 'selection, detail, status and glyph widths passed'))
