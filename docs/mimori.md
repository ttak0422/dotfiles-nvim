# Mimori / Komado integration

This development integration keeps the generic Lua client and thin Komado
adapter in dotfiles-nvim. It requires mimori's v1 query contract and `ensure`.
There is no separate Neovim plugin and no Komado core change.

The tracked legacy hook wrappers now perform only bounded durable ingest.
No historical JSON/database is removed. The initial integration left installed
provider configuration untouched. On 2026-10-04, after explicit user authorization,
only owned Komado hooks in the local `~/.claude/settings.json` and
`~/.codex/config.toml` were migrated to the tracked registration examples.
Unrelated settings/hooks, Codex trust hashes and the separate `hooks.json` were
verified unchanged by before/after comparison. All owned commands use the absolute
pinned mimori executable; no state-directory override was added, retaining the CLI
default (`$XDG_STATE_HOME/mimori` or `~/.local/state/mimori`) shared by the consumer.
No real provider session was launched. Codex hook review and provider/Neovim
restarts remain manual activation steps. The old JSON polling, name completion,
reaper, and Clean commands are gone.

Current provider registration fragments and migration gaps are documented in the
[Claude bridge](../v2/scripts/claude-hooks/README.md#registration-claude-code-21281--mimori-c5b0d92)
and [Codex bridge](../v2/scripts/codex-hooks/README.md#registration-codex-cli-01592--mimori-c5b0d92).
They match the installed Claude Code 2.1.281 / Codex CLI 0.159.2 contracts and the
locked mimori, not a local backend checkout. Only owned Komado handlers should be
replaced; the tracked fragments do not automatically edit installed settings.
The bridge READMEs distinguish the initial audit gaps from the applied local migration.

`:KomadoToggle` subscribes only while its real window/buffer is visible in the
current tab. Entries are grouped under Claude / Codex, with other provider names
kept separately. The provider heading's one-cell glyph shows transport state;
`?` / `:MimoriStatus` opens full status and diagnostics. `r` refreshes,
`a` / `:MimoriAll` opens all summary entries, and Enter opens an entry's detail.
A separate status/detail/all view keeps its own subscription while visible in the current tab; hiding it pauses
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
The default summary-row budget is 10 (`require('mimori.komado').setup({cap=10})`),
shared between providers and including uncertain-hierarchy entries. Allocation is
round-robin between provider groups; provider headers and overflow rows are extra.
Each provider keeps stable session-ID ordering. See [actual sidebar previews and
notation](mimori-sidebar.md).

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

`flake.nix` declares the public `v2-mimori` input, pinned by `flake.lock`.
Its `inputs.nixpkgs.follows = "nixpkgs"` shares the consumer's existing nixpkgs
input. `v2/default.nix` consumes `inputs'.v2-mimori.packages.default` for both
`extraPackages` and the client binary path. The package and Go dependency hash
are defined by mimori itself; there is no duplicate consumer derivation or
mimori entry in the Lua-plugin pins.

Sharing the nixpkgs input avoids retaining a separate nixpkgs revision for mimori.
It does not eliminate source archives, compiler dependencies, or output artifacts;
local compilation is expected. No additional binary-cache service is required.

For local development, pass `--override-input v2-mimori path:/absolute/checkout`
to a flake command. This intentionally substitutes local source. Tests use
temporary state and synthetic provider fixtures. No environment activation or
service-manager installation is performed.

## Validation (2026-10-04, aarch64-darwin)

Use an **unwrapped** Neovim binary: the installed wrapper may inject production
configuration even with `--clean`. Python 3 is needed for synthetic CLI fixtures.
The hook-registration suite needs Python 3.11+ (`tomllib`).
`MIMORI_KOMADO` must point to an isolated Komado checkout/archive at
`8123dd659efb4a9e851dce6a97aed2d6a23dc61a`; no full personal configuration is loaded.

```sh
MIMORI_TEST_NVIM=/absolute/unwrapped/nvim \
MIMORI_KOMADO=/absolute/pinned-komado \
python3 tests/mimori/run.py

MIMORI_TEST_NVIM=/absolute/unwrapped/nvim \
MIMORI_BIN=/absolute/mimori \
python3 tests/mimori/integration.py

MIMORI_BIN=/absolute/pinned/mimori python3 tests/mimori/hooks.py
```

The hook suite parses both tracked fragments and invokes their commands with
isolated state and a PATH without mimori. It checks every registered event,
Notification filtering, provider routing, offline ingest, anonymous wait
conservatism, SessionEnd, and Claude child elicitation aggregation. It owns and
stops only a foreground test daemon; it never loads installed provider settings
or invokes a live agent. The existing client/Komado and shared-daemon suites
remain separate.

The live integration harness currently uses macOS `/usr/sbin/lsof` to identify
and stop only the daemon owning its temporary socket. It verifies cleanup and
removes temporary state. Linux client/runtime behavior was not tested here.
Socket/process tests require an environment that permits Unix socket binding.

Verified with Neovim 0.12.5:

- Generic client: synthetic CLI fixtures; serialized process lock detects any
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
- The public flake input is locked to
  `c5b0d92d511c41be3344a6660778c6ddaa4ab786`. The lock-graph check confirms that
  only the `v2-mimori` node and root edge were added, all existing nodes stayed
  unchanged, and `v2-mimori/nixpkgs` follows the root nixpkgs input.
- The upstream package build (including backend tests) and matching upstream
  package check passed using the shared nixpkgs input.

To build the exact mimori package used by this configuration from its root:

```sh
nix build --impure --no-link --expr '
  let flake = builtins.getFlake (toString ./.);
  in flake.inputs.v2-mimori.packages.${builtins.currentSystem}.default'
```

The complete `packages.aarch64-darwin.bundler-nvim-v2.drvPath` evaluation also
passed with existing deprecation warnings. The complete editor closure was not built.

Full Neovim environment activation was not performed. Local installed hook
registration was migrated as described above, but live provider delivery was not
tested and Codex command review remains pending. This branch does not alter CI
workflows or secrets. Existing CI runs on main pushes or manual dispatch, so draft
PRs do not trigger it.
