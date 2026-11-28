package main

import (
	"context"
	"os"

	"github.com/Shougo/goda-skk.vim/engine"
)

// Filled by Nix; the global dictionary is immutable and available offline.
var dictionary string

func main() {
	// Tests and explicitly offline sessions can avoid probing the host daemon.
	serverRunning := os.Getenv("GODA_SKK_SERVER") != "off" && yaskkservRunning(context.Background(), lsof)
	engine.Main(engine.Config{
		Dictionaries:   []engine.Dictionary{selectDictionary(engine.NewJisyo(dictionary, "euc-jp"), serverRunning)},
		UserDictionary: "-", // Do not load or write a client-side learned dictionary.
		KanaTable:      engine.RomTable.With(engine.Rule{From: "jk", Func: "disable"}),
		EggLikeNewline: true,
	})
}
