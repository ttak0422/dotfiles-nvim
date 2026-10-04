# Mimori / Komado integration

This development integration keeps the generic Lua client and thin Komado
adapter in dotfiles-nvim. It requires mimori's v1 query contract and `ensure`.
There is no separate Neovim plugin and no Komado core change.

The tracked legacy hook wrappers now perform only bounded durable ingest.
No installed provider configuration is edited, and no historical JSON/database
is removed. Activation requires adopting these tracked files, reviewing owned
hook registrations, making mimori available to hook processes, and restarting
Neovim. The old JSON polling, name completion, reaper, and Clean commands are gone.

`:KomadoToggle` subscribes only while its real window/buffer is visible in the
current tab. `r` refreshes, `a` / `:MimoriAll` opens all roots and unclassified
sessions, and Enter opens a root's on-demand detail. A separate detail/all view
keeps its own subscription while visible in the current tab; hiding it pauses
polling, and closing it releases the view; `q` closes it. Selection in
the all view follows provider/session identity. Root details expose backend
aggregate counters and own request IDs, not a reconstructed descendant tree.

Waiting counts with `+?` are lower bounds. Unknown attention and unknown semantic
states remain explicit; unknown liveness is not idle. A connection failure retains
old observations and marks transport health separately. Names and paths are
sanitized and display-width limited. Rendering never reads files or launches
processes in the mimori component.

Set `vim.g.mimori` before lazy loading Komado to override `binary`, `state_dir`
(absolute), `provider`, `interval`, `timeout`, `ensure_timeout`, `max_backoff`,
`max_stdout`, or `max_stderr`. Defaults are 2 s between completed polls, 1 s query
timeout, 6 s outer startup timeout, 30 s maximum retry backoff, 4 MiB stdout and
16 KiB stderr. These are adjustable PoC limits, not provider latency guarantees.
The default root cap is 10 (`require('mimori.komado').setup({cap=10})`).

Generic API: `setup(opts)`, `subscribe(callback)` returning an idempotent release,
`snapshot()` (cached read-only value), `refresh()` (one request when unobserved),
`detail(provider, session_id, callback)` returning cancel, and `shutdown()`.
There is one summary scope/cache per editor; setup changes invalidate it and
cancel old callbacks. Lifecycle, summary, and detail calls share one serialized queue. Same-ID detail
calls coalesce; summary work cannot be starved by repeated detail requests. No client
shutdown/release stops the shared collector. A later view reconnects via ensure.

The client treats revision as an opaque string and preserves large generation
integers. Initial results must be complete; unchanged requires an exact cached
validator. Malformed/oversized/incompatible responses retain the last good cache.

## Source and build

`v2/npins/sources.json` pins mimori separately from Lua plugins. `v2/mimori.nix`
builds its CLI with the pinned Go dependency hash. The source URL contains no
credentials. For authorized private repositories the evaluator needs the user's
existing Git authentication; public CI cannot fetch a private source without
separately authorized credentials. Do not put credentials into pins, derivations,
or URLs, and do not upload private source to public caches.

For local development, use `NPINS_OVERRIDE_mimori=/absolute/mimori/checkout` with
`--impure`. This intentionally substitutes local source and is not a reproducible
release build. Tests use temporary state and synthetic provider fixtures, never
installed provider hooks or personal transcripts. No launchd/systemd installation
or environment activation is performed.

## Clean-room boundary

Implementation used the behavior-only handoff `/tmp/mimori-integration-spec.md`,
mimori's current CLI/schema, dotfiles integration/build files, and the public
Komado integration API at `8123dd659efb4a9e851dce6a97aed2d6a23dc61a`.
No reference terminal implementation, history, tests, or architecture were read.

## Validation (2026-10-04, aarch64-darwin)

Use an **unwrapped** Neovim binary: the installed wrapper may inject production
configuration even with `--clean`. Python 3 is needed for synthetic CLI fixtures.
`MIMORI_KOMADO` must point to an isolated checkout/archive at the pinned Komado
commit above; no full personal configuration is loaded.

```sh
MIMORI_TEST_NVIM=/absolute/unwrapped/nvim \
MIMORI_KOMADO=/absolute/pinned-komado \
python3 tests/mimori/run.py

MIMORI_TEST_NVIM=/absolute/unwrapped/nvim \
MIMORI_BIN=/absolute/mimori \
python3 tests/mimori/integration.py
```

The live integration harness currently uses macOS `/usr/sbin/lsof` to identify
and stop only the daemon owning its temporary socket. It verifies cleanup and
removes temporary state. Linux client/runtime behavior was not tested here.
A sandbox that forbids Unix socket binding needs an authorized native test run;
the sandbox failure was explicitly `bind: operation not permitted`.

Verified with Neovim 0.12.5:

- Generic client: 47 synthetic CLI calls; serialized process lock detects any
  overlap. Includes uint64 preservation, revision/unchanged validation, empty,
  malformed/incomplete/duplicate/version responses, output bounds, timeout,
  missing executable, retained-cache recovery, detail coalescing/cancel,
  release/reopen, scope/setup changes, subscriber exceptions, and request storms.
- Pinned Komado: 6 redraws during visible lifecycle exercise; unchanged polls cause
  zero additional redraws. Initially hidden, retained-buffer close, ordinary
  window close, hidden-tab all view and final shutdown each produce zero
  periodic requests. Detail hidden during fetch refetches on visibility resume.
- Real daemon: two concurrent editors share one collector. Closing both leaves
  it queryable; a third editor reconnects after collector restart. One root
  aggregates 50 running descendants. A synthetic Codex permission remains
  discoverable with unknown attention/inexact count. Test-owned daemon removed.
- 40 CLI-inclusive unchanged queries: p50 **8.85 ms**, p95 **9.81 ms**; response
  **97 bytes**, full fixture snapshot **924 bytes**. This small local fixture
  supports conservative 2 s polling/1 s query timeout defaults; it is not a
  production workload guarantee.
- Nix exact private-source pin evaluation and CLI derivation build (including
  backend tests) passed with existing host Git authentication, both with a local
  source override and without it. No credentials added, cache upload, activation,
  or service-manager installation. The resulting CLI was
  `/nix/store/zaclzznbx7a6scbjhkq8izxbxny1c26n-mimori-0.1.0-2ebb1cc`.

To reproduce the standalone CLI build using an available pinned nixpkgs source:

```sh
nix build --impure --no-link --expr '
  let pkgs = import /absolute/pinned-nixpkgs { system = builtins.currentSystem; };
  in import /absolute/dotfiles-nvim/v2/mimori.nix { inherit pkgs; }'
```

The complete `packages.aarch64-darwin.bundler-nvim-v2.drvPath` evaluation also
passed (`/nix/store/0997ma1k7shqxl56a5vhzxbzsvvnwxhl-neovim-0.12.5v2.drv`),
with existing deprecation warnings. The complete editor closure was not built.

Full Neovim environment activation and live provider hook registration were not
performed. Public CI still requires separately authorized access to private
mimori; this branch does not alter workflows, secrets, or repository visibility.
