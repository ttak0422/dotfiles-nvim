package main

import (
	"bufio"
	"context"
	"net"
	"os"
	"path/filepath"
	"reflect"
	"slices"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/Shougo/goda-skk.vim/dictionary/skkserv"
	"github.com/Shougo/goda-skk.vim/engine"
	"golang.org/x/text/encoding/japanese"
)

// Reuse the test executable as lsof, without depending on a system shell.
func TestMain(m *testing.M) {
	if os.Getenv("GODA_TEST_LSOF") == "1" {
		if strings.Join(os.Args[1:], " ") != "-nP -a -iTCP:1178 -sTCP:LISTEN -F c" {
			os.Exit(2)
		}
		os.Stdout.WriteString(os.Getenv("GODA_TEST_LSOF_OUTPUT"))
		code, _ := strconv.Atoi(os.Getenv("GODA_TEST_LSOF_EXIT"))
		os.Exit(code)
	}
	os.Exit(m.Run())
}

func TestYaskkservRunning(t *testing.T) {
	for _, tc := range []struct {
		name, output string
		exit         int
		want         bool
	}{
		{"yaskkserv", "p123\ncyaskkserv\n", 0, true},
		{"yaskkserv2", "p123\ncyaskkserv2\n", 0, true},
		{"different server", "p123\ncpython\n", 0, false},
		{"not a command field", "p123\nn/tmp/yaskkserv\n", 0, false},
		{"no listener", "", 1, false},
		{"failed detection", "cyaskkserv\n", 1, false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			path, err := os.Executable()
			if err != nil {
				t.Fatal(err)
			}
			// The race runtime otherwise delays helper exit by one second.
			t.Setenv("GORACE", "atexit_sleep_ms=0")
			t.Setenv("GODA_TEST_LSOF", "1")
			t.Setenv("GODA_TEST_LSOF_OUTPUT", tc.output)
			t.Setenv("GODA_TEST_LSOF_EXIT", strconv.Itoa(tc.exit))
			if got := yaskkservRunning(context.Background(), path); got != tc.want {
				t.Fatalf("detected %v, want %v", got, tc.want)
			}
		})
	}
	t.Run("missing lsof", func(t *testing.T) {
		if yaskkservRunning(context.Background(), filepath.Join(t.TempDir(), "missing")) {
			t.Fatal("missing executable enabled server")
		}
	})
	t.Run("cancelled detection", func(t *testing.T) {
		ctx, cancel := context.WithCancel(context.Background())
		cancel()
		if yaskkservRunning(ctx, "/bin/sh") {
			t.Fatal("cancelled detection enabled server")
		}
	})
}

func localDictionary(t *testing.T) *engine.Jisyo {
	t.Helper()
	path := filepath.Join(t.TempDir(), "SKK-JISYO.local")
	data := ";; okuri-ari entries.\nおくr /贈/\n;; okuri-nasi entries.\nかんじ /幹字/\nかんたん /簡単/\nろーかる /地元/\n"
	if err := os.WriteFile(path, []byte(data), 0600); err != nil {
		t.Fatal(err)
	}
	return engine.NewJisyo(path, "utf-8")
}

func TestSelectDictionary(t *testing.T) {
	local := localDictionary(t)
	if got := selectDictionary(local, false); got != local {
		t.Fatal("stopped server must select only the local dictionary")
	}
	got, ok := selectDictionary(local, true).(*serverOrLocal)
	if !ok || got.local != local || got.server == nil {
		t.Fatal("running server must select a single server/fallback dictionary")
	}
}

// A local EUC-JP SKK protocol fixture. It never contacts the user's daemon or
// external dictionaries, and can close existing connections or stop responding.
type fakeServer struct {
	ln      net.Listener
	entries map[string]string
	stall   atomic.Bool
	mu      sync.Mutex
	conns   map[net.Conn]bool
	closed  bool
	wg      sync.WaitGroup
}

func startServer(t *testing.T, addr string) *fakeServer {
	t.Helper()
	ln, err := net.Listen("tcp", addr)
	if err != nil {
		t.Fatal(err)
	}
	s := &fakeServer{
		ln: ln,
		entries: map[string]string{
			"かんじ": "/漢字/感じ/",
			"おくr": "/送/[る/送/]/",
		},
		conns: make(map[net.Conn]bool),
	}
	s.wg.Add(1)
	go func() {
		defer s.wg.Done()
		for {
			conn, err := ln.Accept()
			if err != nil {
				return
			}
			s.mu.Lock()
			if s.closed {
				conn.Close()
				s.mu.Unlock()
				return
			}
			s.conns[conn] = true
			s.wg.Add(1)
			s.mu.Unlock()
			go s.serve(conn)
		}
	}()
	t.Cleanup(s.stop)
	return s
}

func (s *fakeServer) serve(conn net.Conn) {
	defer s.wg.Done()
	defer func() {
		conn.Close()
		s.mu.Lock()
		delete(s.conns, conn)
		s.mu.Unlock()
	}()
	r := bufio.NewReader(conn)
	for {
		b, err := r.ReadBytes(' ')
		if err != nil {
			return
		}
		if s.stall.Load() {
			continue
		}
		cmd, err := japanese.EUCJP.NewDecoder().String(strings.TrimSuffix(string(b), " "))
		if err != nil || len(cmd) < 2 {
			return
		}
		answer := "4" + cmd[1:] + " "
		switch cmd[0] {
		case '1':
			if candidates, ok := s.entries[cmd[1:]]; ok {
				answer = "1" + candidates
			}
		case '4':
			var words []string
			for word := range s.entries {
				if strings.HasPrefix(word, cmd[1:]) {
					words = append(words, word)
				}
			}
			slices.Sort(words)
			answer = "1/" + strings.Join(words, "/") + "/"
		}
		out, err := japanese.EUCJP.NewEncoder().String(answer + "\n")
		if err != nil {
			return
		}
		if _, err := conn.Write([]byte(out)); err != nil {
			return
		}
	}
}

func (s *fakeServer) stop() {
	s.mu.Lock()
	s.closed = true
	s.ln.Close()
	for conn := range s.conns {
		conn.Close()
	}
	s.mu.Unlock()
	s.wg.Wait()
}

func testDictionary(t *testing.T, s *fakeServer) *serverOrLocal {
	t.Helper()
	d := &serverOrLocal{
		server: skkserv.New(skkserv.Params{Addr: s.ln.Addr().String(), Timeout: 100 * time.Millisecond}),
		local:  localDictionary(t),
	}
	t.Cleanup(func() { d.Close() })
	return d
}

func assertLookup(t *testing.T, d engine.Dictionary, word string, want []string) {
	t.Helper()
	got, err := d.Lookup(context.Background(), engine.OkuriNasi, word)
	if err != nil || !slices.Equal(got, want) {
		t.Fatalf("lookup %s = %v, %v; want %v", word, got, err, want)
	}
}

func TestServerDoesNotMergeLocalCandidates(t *testing.T) {
	s := startServer(t, "127.0.0.1:0")
	d := testDictionary(t, s)
	if err := d.Init(context.Background()); err != nil {
		t.Fatal(err)
	}
	assertLookup(t, d, "かんじ", []string{"漢字", "感じ"})
	assertLookup(t, d, "ろーかる", nil) // A miss is not a connection failure.
	got, err := d.Lookup(context.Background(), engine.OkuriAri, "おくr")
	if err != nil || !slices.Equal(got, []string{"送"}) {
		t.Fatalf("okuri: %v, %v", got, err)
	}
	entries, err := d.Complete(context.Background(), "かん")
	want := []engine.Entry{{Word: "かんじ", Candidates: []string{"漢字", "感じ"}}}
	if err != nil || !reflect.DeepEqual(entries, want) {
		t.Fatalf("complete: %v, %v; want %v", entries, err, want)
	}
	entries, err = d.Complete(context.Background(), "ろー")
	if err != nil || len(entries) != 0 {
		t.Fatalf("empty server completion included local entries: %v, %v", entries, err)
	}
}

func TestServerGoneBeforeInitialization(t *testing.T) {
	s := startServer(t, "127.0.0.1:0")
	d := testDictionary(t, s)
	s.stop() // It was detected, then exited before Goda connected.
	if err := d.Init(context.Background()); err == nil {
		t.Fatal("expected the initial connection to fail")
	}
	assertLookup(t, d, "かんじ", []string{"幹字"})
	var wg sync.WaitGroup
	for range 8 {
		wg.Go(func() {
			got, err := d.Lookup(context.Background(), engine.OkuriNasi, "かんじ")
			if err != nil || !slices.Equal(got, []string{"幹字"}) {
				t.Errorf("concurrent offline lookup: %v, %v", got, err)
			}
		})
	}
	wg.Wait()
}

func TestServerStopAndRestart(t *testing.T) {
	s := startServer(t, "127.0.0.1:0")
	addr := s.ln.Addr().String()
	d := testDictionary(t, s)
	assertLookup(t, d, "かんじ", []string{"漢字", "感じ"})
	s.stop()
	assertLookup(t, d, "かんじ", []string{"幹字"})
	assertLookup(t, d, "ろーかる", []string{"地元"}) // Still works during reconnect cooldown.
	entries, err := d.Complete(context.Background(), "かん")
	want := []engine.Entry{
		{Word: "かんじ", Candidates: []string{"幹字"}},
		{Word: "かんたん", Candidates: []string{"簡単"}},
	}
	if err != nil || !reflect.DeepEqual(entries, want) {
		t.Fatalf("offline completion: %v, %v; want %v", entries, err, want)
	}
	startServer(t, addr)
	// v0.3.3 deliberately waits five seconds after a failed dial. The same
	// dictionary must recover without rebuilding the plugin or restarting Vim.
	deadline := time.Now().Add(8 * time.Second)
	for {
		got, err := d.Lookup(context.Background(), engine.OkuriNasi, "かんじ")
		if err != nil {
			t.Fatal(err)
		}
		if slices.Equal(got, []string{"漢字", "感じ"}) {
			break
		}
		if time.Now().After(deadline) {
			t.Fatalf("server did not recover: %v", got)
		}
		time.Sleep(25 * time.Millisecond)
	}
	assertLookup(t, d, "ろーかる", nil)
}

func TestServerTimeoutAndRecovery(t *testing.T) {
	s := startServer(t, "127.0.0.1:0")
	d := testDictionary(t, s)
	s.stall.Store(true)
	assertLookup(t, d, "かんじ", []string{"幹字"})
	s.stall.Store(false)
	assertLookup(t, d, "かんじ", []string{"漢字", "感じ"})
}

func TestServerClose(t *testing.T) {
	s := startServer(t, "127.0.0.1:0")
	d := testDictionary(t, s)
	assertLookup(t, d, "かんじ", []string{"漢字", "感じ"})
	if err := d.Close(); err != nil {
		t.Fatal(err)
	}
	deadline := time.Now().Add(time.Second)
	for {
		s.mu.Lock()
		count := len(s.conns)
		s.mu.Unlock()
		if count == 0 {
			return
		}
		if time.Now().After(deadline) {
			t.Fatal("server connection remains open")
		}
		time.Sleep(time.Millisecond)
	}
}
