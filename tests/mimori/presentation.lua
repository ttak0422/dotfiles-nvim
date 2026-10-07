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
local pressure={}
for i=1,12 do pressure[#pressure+1]=session('claude',string.format('a-ended-%02d',i),'ended') end
for i=1,6 do pressure[#pressure+1]=session('codex',string.format('z-working-%02d',i),'running') end
local same_provider={session('claude','a-ended','ended'),session('claude','b-ended','ended'),
  session('claude','z-running','running'),session('claude','y-idle','idle'),session('claude','x-unknown','unknown')}
local ended_parent=session('codex','a-ended-parent','ended');ended_parent.aggregate_state='running';ended_parent.running_descendants=2
local same_project={session('codex','01912345-a91f','running'),session('codex','01912345-0bc8','idle')}
for _,row in ipairs(same_project) do row.name=nil;row.cwd='/home/example/mimori' end
same_project[1].unresolved_requests=2;same_project[1].running_descendants=4
local named_project={session('claude','named-one','running'),session('claude','named-two','idle')}
named_project[1].name='認証修正';named_project[1].cwd='/home/example/mimori'
named_project[2].name='👩‍💻 日本語の幅調整';named_project[2].cwd='/home/example/dotfiles-nvim'
local empty_metadata=session('claude','empty-7d2c','unknown');empty_metadata.name='  ';empty_metadata.cwd=' '
local suffixes={session('codex','01912345-11beef','idle'),session('codex','01912345-22beef','idle')}
for _,row in ipairs(suffixes) do row.name='同名の作業';row.cwd='/home/example/mimori' end
local clipped={session('claude','task-aa11','idle'),session('claude','task-bb22','idle')}
clipped[1].name='日本語の長い作業名その一';clipped[2].name='日本語の長い作業名その二'
local many_children=session('claude','parent-91ff','running');many_children.name=nil;many_children.cwd='/home/example/mimori'
many_children.running_descendants=50;many_children.unresolved_requests=2
local cases={
  {'project-fallback',snapshot(same_project)}, {'named-project',snapshot(named_project)},
  {'empty-metadata',snapshot({empty_metadata})}, {'suffix-collision',snapshot(suffixes)},
  {'truncated-labels',snapshot(clipped)}, {'many-children-label',snapshot({many_children})},
  {'empty',snapshot()}, {'connected-idle',snapshot({c})}, {'populated',snapshot({c,x})},
  {'unknown-wait',snapshot({c},{u})}, {'connecting',{status='loading'}},
  {'disconnected',{status='error',diagnostic='collector socket unavailable'}},
  {'paused',snapshot({c},{},'paused')},
  {'wide-name',snapshot({session('claude','日本語の長いセッション名と進捗確認','running')})},
  {'error-retained',failed}, {'overflow',snapshot(overflow)},
  {'all-states',snapshot({session('claude','a-running','running'),session('claude','b-waiting','waiting'),session('claude','c-idle','idle'),session('claude','d-ended','ended'),session('claude','e-unknown','unknown'),session('claude','f-future','future-state')})},
  {'other-provider',snapshot({session('demo','custom-session','unknown')})},
  {'ended-pressure',snapshot(pressure)}, {'ended-last',snapshot(same_provider)},
  {'ended-parent',snapshot({ended_parent})},
  {'ended-only',snapshot({session('claude','finished-review','ended'),session('codex','finished-implementation','ended')})},
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
for _,width in ipairs({28,32,40}) do
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
      if case[1]=='project-fallback' then
        assert(text:find('mimori #a91f',1,true) and text:find('mimori #0bc8',1,true),'project/suffix missing from real render')
      end
      if case[1]=='named-project' then
        assert(text:find('認証修正',1,true) and text:find('mimori',1,true),'task/project lost from real render')
      end
      if case[1]=='empty-metadata' then assert(text:find('名前なし #7d2c',1,true)) end
      if case[1]=='suffix-collision' then assert(text:find('#11beef',1,true) and text:find('#22beef',1,true)) end
      if case[1]=='truncated-labels' and width==28 then assert(text:find('#aa11',1,true) and text:find('#bb22',1,true)) end
      if case[1]=='many-children-label' then assert(text:find('● W2 R50 mimori',1,true)) end
      if case[1]=='unknown-wait' then assert(text:find('● W2+? R0 ~',1,true),'counts or uncertainty truncated') end
      if case[1]=='populated' then assert(text:find('● W0 R50',1,true)) end
      if case[1]=='other-provider' then assert(text:find('Other: demo',1,true)) end
      if case[1]=='ended-pressure' then
        assert(text:find('z-working-06',1,true),'ended history stole active slots')
        assert(text:find('+8 more · wait 0 · a',1,true),'ended overflow incorrect')
      end
      if case[1]=='ended-last' then assert(text:find('z-running',1,true)<text:find('a-ended',1,true)) end
      if case[1]=='ended-parent' then assert(text:find('● W0 R2',1,true),'ended parent lost active descendants') end
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
  assert(a.state_icon('running')=='●' and a.state_icon('waiting')=='●' and a.state_icon('ended')=='●',
    'active/attention/completed states should share a round marker')
  assert(a.state_icon('idle')=='○' and a.state_icon('unknown')=='○' and a.state_icon('future-state')=='○',
    'idle/unknown states should retain their quiet outline')
  local colors={running=0xffcc66,waiting=0xff77aa,idle=0x99cc88,ended=0x66cccc,unknown=0x808080}
  local links={running='DiagnosticWarn',waiting='DiagnosticError',idle='DiagnosticOk',ended='DiagnosticInfo',unknown='Comment'}
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
  for _,width in ipairs({28,32,40}) do
    vim.api.nvim_win_set_width(k.get_state().winid,width);k.redraw();vim.wait(20)
    check_colors(k.get_state().bufnr,true)
  end
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
  for i,line in ipairs(lines(buf)) do if line:find('● W2+? R0 ~',1,true) then target=i end end
  assert(target);vim.api.nvim_win_set_cursor(win,{target,0})
  publish(snapshot({x,session('claude','aaa-new','idle'),c},{u}));vim.wait(30)
  assert(vim.api.nvim_get_current_line():find('● W2+? R0 ~',1,true),'selection changed identity')
  -- Moving a selected identity from active to ended preserves all-view selection.
  local ended=vim.deepcopy(u);ended.state='ended';ended.aggregate_state='ended'
  ended.unresolved_requests=0;ended.unresolved_count_exact=true;ended.attention_unknown=false
  publish(snapshot({c,x},{ended}));vim.wait(30)
  assert(vim.api.nvim_get_current_line():find('12345678-',1,true),'ending moved selection to another identity')
  assert(vim.api.nvim_get_current_line():find('● W0 R0',1,true),'all view lost ended row')
  -- Renaming labels never changes selection identity or the PR9 ID sort order.
  publish(snapshot(same_project));a.open_all();vim.wait(30)
  local labels_win=vim.api.nvim_get_current_win()
  local chosen
  for i,line in ipairs(lines(0)) do if line:find('#a91f',1,true) then chosen=i end end
  assert(chosen);vim.api.nvim_win_set_cursor(labels_win,{chosen,0})
  for _,width in ipairs({28,32,40}) do
    vim.api.nvim_win_set_width(labels_win,width)
    vim.api.nvim_exec_autocmds('WinResized',{});vim.wait(20)
    assert(vim.api.nvim_get_current_line():find('#a91f',1,true),'resize changed selected identity')
    for _,line in ipairs(lines(0)) do assert(vim.fn.strdisplaywidth(line)<=width-2,'all-view width was not recomputed') end
  end
  local renamed=vim.deepcopy(same_project)
  renamed[1].name='新しい作業名';renamed[2].name='別の作業名'
  publish(snapshot({renamed[2],renamed[1]}));vim.wait(30)
  assert(vim.api.nvim_get_current_line():find('新しい作業名',1,true),'label change moved the selected identity')
  a.open_detail(renamed[1]);vim.wait(30)
  local label_detail=table.concat(lines(0),'\n')
  assert(label_detail:find('session_id: 01912345-a91f',1,true),'detail queried a display suffix')
  assert(label_detail:find('cwd: /home/example/mimori',1,true) and label_detail:find('name: 新しい作業名',1,true))
  assert(label_detail:find('label_source: name',1,true),'detail lost label provenance')
  -- The original snapshot/identity stays available to details despite reordering.
  publish(snapshot({c,x},{u}));vim.wait(30)
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
print('presentation: rendered '..#cases..' cases at 28/32/40 columns; '..(vim.env.MIMORI_BASELINE and 'baseline buffers captured' or 'selection, detail, status and glyph widths passed'))
