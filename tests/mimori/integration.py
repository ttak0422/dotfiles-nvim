#!/usr/bin/env python3
"""Use explicit unwrapped Neovim and mimori paths; isolated anonymous state only."""
import json, os, signal, statistics, subprocess, tempfile, time
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
NVIM, MIMORI = os.environ['MIMORI_TEST_NVIM'], os.environ['MIMORI_BIN']
def call(*args, **kwargs):
    return subprocess.run(args, check=True, capture_output=True, text=True, **kwargs)
def wait(fn, timeout=12):
    end=time.monotonic()+timeout
    while time.monotonic()<end:
        result=fn()
        if result: return result
        time.sleep(.025)
    raise AssertionError('deadline expired')
with tempfile.TemporaryDirectory(prefix='mimori-nvim-',dir='/tmp') as temporary:
    temp=Path(temporary); state=temp/'state'; state.mkdir(mode=0o700)
    env=os.environ.copy(); env.update(HOME=str(temp/'home'),XDG_STATE_HOME=str(temp/'xdg-state'),
      XDG_CACHE_HOME=str(temp/'cache'),XDG_DATA_HOME=str(temp/'data'),MIMORI_BIN=MIMORI,
      MIMORI_STATE_DIR=str(state),MIMORI_TEST_ROOT=str(ROOT))
    for path in ('home','xdg-state/nvim','cache','data'): (temp/path).mkdir(parents=True,exist_ok=True)
    children=[]
    def query(revision=None):
        args=[MIMORI,'query','--state-dir',str(state)]
        if revision: args += ['--revision',revision]
        r=subprocess.run(args,capture_output=True,text=True)
        return json.loads(r.stdout) if r.returncode==0 else None
    def daemon_pid():
        r=subprocess.run(['/usr/sbin/lsof','-t',str(state/'query.sock')],capture_output=True,text=True)
        pids=set(r.stdout.split())
        for pid in pids:
            command=call('ps','-p',pid,'-o','command=').stdout
            if str(state) in command and 'daemon' in command: return int(pid)
        return None
    def stop_daemon():
        pid=daemon_pid()
        if pid:
            os.kill(pid,signal.SIGTERM)
            wait(lambda:not (state/'query.sock').exists())
    def client(index):
        marker=temp/f'ready{index}'; stop=temp/f'stop{index}'
        e=env|{'MIMORI_CLIENT_MARKER':str(marker),'MIMORI_CLIENT_STOP':str(stop)}
        p=subprocess.Popen([NVIM,'--clean','--headless','-u','NONE','-i','NONE','-l',str(ROOT/'tests/mimori/live-client.lua')],env=e,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
        children.append(p)
        return p,marker,stop
    try:
        def ingest(session,relation='root',kind='turn_start',**extra):
            event={'version':1,'event_id':session+'-'+kind,'provider':'demo','session_id':session,'generation':1,
                'kind':kind,'relation':relation,'observed_at':'2026-10-03T00:00:00Z',**extra}
            call(MIMORI,'ingest','--state-dir',str(state),input=json.dumps(event),env=env)
        ingest('root',cwd='/anonymous',name='same')
        for i in range(50): ingest('child'+str(i),'child',parent_id='root',parent_generation=1)
        hook={'session_id':'codex-anonymous','hook_event_name':'PermissionRequest','cwd':'/anonymous','tool_name':'Bash','tool_input':{}}
        call(str(ROOT/'v2/scripts/codex-hooks/komado-codex-hook.sh'),input=json.dumps(hook),env=env)
        assert query() is None, 'ingestion started daemon'
        one,ready1,stop1=client(1); two,ready2,stop2=client(2)
        wait(lambda:ready1.exists() and ready2.exists())
        snap=query(); assert len(snap['roots'])==1 and snap['roots'][0]['running_descendants']==50
        assert snap['unclassified'][0]['attention_unknown'] and not snap['unclassified'][0]['unresolved_count_exact']
        pid=daemon_pid(); assert pid
        call(MIMORI,'ensure','--state-dir',str(state),env=env); assert daemon_pid()==pid
        stop1.touch(); assert one.wait(timeout=5)==0; assert query()['revision']==snap['revision']
        stop2.touch(); assert two.wait(timeout=5)==0; assert query()['revision']==snap['revision']
        three,ready3,stop3=client(3); wait(ready3.exists)
        stop_daemon()
        wait(lambda:(query() or {}).get('revision') not in (None,snap['revision']))
        assert daemon_pid()!=pid, 'restart did not change daemon'
        stop3.touch(); assert three.wait(timeout=5)==0
        durations=[]; sizes=[]; revision=query()['revision']
        for _ in range(40):
            start=time.perf_counter(); response=call(MIMORI,'query','--state-dir',str(state),'--revision',revision,env=env)
            durations.append((time.perf_counter()-start)*1000); sizes.append(len(response.stdout.encode()))
            assert json.loads(response.stdout)['unchanged']
        print(json.dumps({'result':'passed','editors':3,'root_descendants':50,'daemon_reuse':True,'restart':True,
          'polls':40,'p50_ms':round(statistics.median(durations),2),'p95_ms':round(sorted(durations)[37],2),
          'unchanged_bytes':sizes[0],'full_bytes':len(json.dumps(query(),separators=(',',':')).encode())}))
    finally:
        for p in children:
            if p.poll() is None: p.terminate(); p.wait(timeout=5)
            out,err=p.communicate()
            if p.returncode: print('client diagnostic:',out,err)
        stop_daemon()
        assert daemon_pid() is None, 'test daemon leaked'
