-- Display metadata tests: synthetic records only, with no provider/FS access.
local root = assert(vim.env.MIMORI_TEST_ROOT)
package.path = root .. '/v2/lua/?.lua;' .. package.path
local a, labels = require('mimori.komado'), require('mimori.labels')
local function session(id, extra)
  return vim.tbl_extend('force', { provider='codex', session_id=id, state='idle', aggregate_state='idle',
    classification='resolved', running_descendants=0, unresolved_requests=0,
    unresolved_count_exact=true, attention_unknown=false }, extra or {})
end
local function snapshot(entries, loose)
  return {status='connected', data={roots=entries, unclassified=loose or {}}}
end
local function sessions(rows)
  local result={}; for _,row in ipairs(rows) do if row.session then result[#result+1]=row end end
  return result
end
local function same(a1,b1) assert(vim.deep_equal(a1,b1),vim.inspect({a1,b1})) end
same(labels.describe({name=' \t\n',cwd=' /repo/mimori/// '}),
  {cwd='/repo/mimori///',project='mimori',primary='mimori',source='cwd'})
assert(labels.describe({name='\27[31m\27[0m',cwd=' '}).source=='missing')
assert(labels.describe({cwd='/'}).primary=='/')
assert(labels.describe({name=' task ',cwd='/repo/project'}).primary=='task')
assert(labels.describe({name='task'}).source=='name')

local entries={
  session('01912345-1111-1111-1111-11111111a91f',{cwd='/repo/mimori'}),
  session('01912345-1111-1111-1111-111111110bc8',{cwd='/repo/mimori'}),
  session('01912345-1111-1111-1111-111111117d2c'),
}
local source=snapshot(entries)
local saved=vim.deepcopy(source)
for _,width in ipairs({26,30,38}) do
  local result=sessions(a.rows(source,nil,width))
  for _,row in ipairs(result) do
    assert(vim.fn.strdisplaywidth(row.text)<=width)
    assert(not row.text:find('01912345',1,true),'UUID prefix used as identity label')
  end
  assert(result[1].text:find('#0bc8',1,true) and result[1].text:find('mimori',1,true))
  assert(result[2].text:find('#7d2c',1,true) and result[2].text:find('名前なし',1,true))
  assert(result[3].text:find('#a91f',1,true))
  -- The cap cannot change suffix visibility or make a hidden same-name row vanish from collision checks.
  same(sessions(a.rows(source,1,width))[1],result[1])
end
same(source,saved)

local colliding={session('01912345-aaaa11beef',{name='調査'}),session('01912345-bbbb22beef',{name='調査'})}
local result=sessions(a.rows(snapshot(colliding),nil,26))
assert(result[1].text:find('#11beef',1,true) and result[2].text:find('#22beef',1,true),'short suffix collision not extended')
assert(not result[1].text:find('01912345',1,true))

-- Long common suffixes get bounded fingerprints rather than two identical
-- clipped full IDs that consume all the room reserved for the human label.
local longtails={session('a'..string.rep('z',80),{cwd='/repo/project'}),session('b'..string.rep('z',80),{cwd='/repo/project'})}
local longrows=sessions(a.rows(snapshot(longtails),nil,26))
assert(longrows[1].text~=longrows[2].text)
for _,row in ipairs(longrows) do
  assert(row.text:find('project #~',1,true) and vim.fn.strdisplaywidth(row.text)<=26)
end
-- Display-identical prefixes from different full names also need unique suffixes.
local truncated={session('id-aa11',{name='日本語の長い作業名その一'}),session('id-bb22',{name='日本語の長い作業名その二'})}
for _,width in ipairs({26,30,38}) do
  local rs=sessions(a.rows(snapshot(truncated),nil,width))
  assert(rs[1].text~=rs[2].text,'truncation made labels identical')
  if width==26 then assert(rs[1].text:find('#aa11',1,true) and rs[2].text:find('#bb22',1,true)) end
end
local named=session('title-id',{name='幅調整',cwd='/home/example/dotfiles-nvim'})
for _,width in ipairs({26,30,38}) do
  local row=sessions(a.rows(snapshot({named}),nil,width))[1]
  assert(row.text:find('幅',1,true) and row.text:find(' · ',1,true),'task/project components lost')
  assert(not row.text:find('#',1,true),'unique label unnecessarily gained an ID')
  assert(vim.fn.strdisplaywidth(row.text)<=width)
end
-- Provider grouping and opaque identity are independent of the display label.
local c=vim.deepcopy(entries[1]);c.provider='claude'
result=sessions(a.rows(snapshot({c,entries[1]}),nil,38))
assert(not result[1].text:find('#',1,true) and not result[2].text:find('#',1,true))
local parent=session('parent',{cwd='/repo/mimori',state='ended',aggregate_state='running',running_descendants=50})
local child=session('agent:parent:child',{cwd='/repo/mimori',classification='unclassified',unresolved_count_exact=false})
local tree=snapshot({parent},{child})
local before=vim.deepcopy(tree)
result=sessions(a.rows(tree,nil,26))
assert(result[1].text:find('W0+? R0 ~',1,true),'uncertain child marker lost')
assert(result[2].text:find('W0 R50',1,true),'parent aggregate count lost')
same(tree,before)

for _,ambiwidth in ipairs({'single','double'}) do
  vim.o.ambiwidth=ambiwidth
  for _,value in ipairs({'日本語の長い名前', '👩‍💻👩‍💻👩‍💻', '👍🏽👍🏽', 'ééé', '🇯🇵🇫🇷🇨🇦'}) do
    for width=0,24 do
      local text=labels.clean(value,width)
      assert(vim.fn.strdisplaywidth(text)<=width,'display cell limit exceeded')
      assert(not text:find('‍…',1,true) and not text:find('‍.',1,true),'dangling emoji joiner')
      assert(not text:find('<80>',1,true),'broken UTF-8')
    end
  end
end
vim.o.ambiwidth='single'
local unsafe=session('id\n\27[31m',{name='\27[31mTask\27[0m\nname',cwd='/repo/\npath'})
result=sessions(a.rows(snapshot({unsafe,session('other',{name=unsafe.name})}),nil,38))
for _,row in ipairs(result) do assert(not row.text:find('[%c]'),'display control leaked') end
local system=vim.system;vim.system=function() error('I/O from label rendering') end
a.rows(source,10,26);labels.describe(named)
vim.system=system
print('labels: passed; fallback, metadata, suffix collisions, caps, hierarchy, Unicode and purity verified')
