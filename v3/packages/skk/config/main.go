package main

import (
	"context"
	"log"
	"os"
	"path/filepath"

	"github.com/Shougo/goda-skk.vim/engine"
)

// Filled by Nix; the global dictionary is immutable and available offline.
var dictionary string

func main() {
	state := os.Getenv("GODA_SKK_STATE_DIR")
	if state == "" {
		log.Fatal("GODA_SKK_STATE_DIR is not set")
	}
	if err := os.MkdirAll(state, 0700); err != nil {
		log.Fatal(err)
	}
	// Tests and explicitly offline sessions can avoid probing the host daemon.
	serverRunning := os.Getenv("GODA_SKK_SERVER") != "off" && yaskkservRunning(context.Background(), lsof)
	engine.Main(engine.Config{
		Dictionaries:   []engine.Dictionary{selectDictionary(engine.NewJisyo(dictionary, "euc-jp"), serverRunning)},
		UserDictionary: filepath.Join(state, "SKK-JISYO.user"),
		KanaTable:      engine.RomTable.With(engine.Rule{From: "jk", Func: "escape"}),
		EggLikeNewline: true,
	})
}
