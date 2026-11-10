package main

import (
	"context"
	"errors"
	"os/exec"
	"strings"
	"sync"
	"time"

	"github.com/Shougo/goda-skk.vim/dictionary/skkserv"
	"github.com/Shougo/goda-skk.vim/engine"
)

// Filled by Nix so detection does not depend on the editor's PATH.
var lsof = "lsof"

// Like v2, choose once when the input method starts. Restrict lsof to listeners:
// an unrelated client connected to port 1178 must not enable the server source.
func yaskkservRunning(ctx context.Context, executable string) bool {
	ctx, cancel := context.WithTimeout(ctx, time.Second)
	defer cancel()
	out, err := exec.CommandContext(ctx, executable,
		"-nP", "-a", "-iTCP:1178", "-sTCP:LISTEN", "-F", "c").Output()
	if err != nil {
		return false
	}
	for line := range strings.SplitSeq(string(out), "\n") {
		if strings.HasPrefix(line, "cyaskkserv") {
			return true
		}
	}
	return false
}

func selectDictionary(local engine.Dictionary, serverRunning bool) engine.Dictionary {
	if !serverRunning {
		return local
	}
	return &serverOrLocal{
		server: skkserv.New(skkserv.Params{Addr: "127.0.0.1:1178"}),
		local:  local,
	}
}

// Keep one source in engine.Config: Goda would otherwise merge both dictionaries
// on every lookup. A healthy server's empty answer stays empty; only a transport
// failure uses the local dictionary. The upstream client reconnects automatically.
type serverOrLocal struct {
	// Keep the availability check and request atomic across completion/input.
	mu     sync.Mutex
	server *skkserv.Dictionary
	local  engine.Dictionary
}

func (d *serverOrLocal) Init(ctx context.Context) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	var localErr error
	if init, ok := d.local.(engine.Initializer); ok {
		localErr = init.Init(ctx)
	}
	return errors.Join(localErr, d.server.Init(ctx))
}

func (d *serverOrLocal) Lookup(ctx context.Context, typ engine.HenkanType, word string) ([]string, error) {
	d.mu.Lock()
	defer d.mu.Unlock()
	// Init also reports the upstream client's five-second reconnect cooldown.
	// Lookup alone returns an empty, successful answer during that cooldown,
	// which would incorrectly skip the fallback after a failed connection.
	if err := d.server.Init(ctx); err == nil {
		if candidates, err := d.server.Lookup(ctx, typ, word); err == nil {
			return candidates, nil
		}
	}
	return d.local.Lookup(ctx, typ, word)
}

func (d *serverOrLocal) Complete(ctx context.Context, prefix string) ([]engine.Entry, error) {
	d.mu.Lock()
	defer d.mu.Unlock()
	if err := d.server.Init(ctx); err == nil {
		if entries, err := d.server.Complete(ctx, prefix); err == nil {
			return entries, nil
		}
	}
	return d.local.Complete(ctx, prefix)
}

func (d *serverOrLocal) Close() error {
	d.mu.Lock()
	defer d.mu.Unlock()
	return d.server.Close()
}

var (
	_ engine.Dictionary  = (*serverOrLocal)(nil)
	_ engine.Initializer = (*serverOrLocal)(nil)
)
