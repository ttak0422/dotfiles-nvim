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
`a` / `:MimoriAll` opens all summary entries, and Enter opens an entry's detail
in a separate split. On a sidebar agent row, `K` opens the same detail in a bounded
hover without moving focus; a second `K` focuses it for scrolling. `q` / Escape
inside the hover closes it. Moving the sidebar cursor, leaving the sidebar/hover,
changing tab, closing the sidebar, or resizing dismisses it and cancels stale work.
Round state markers emphasize theme-linked colors, with quiet idle/unknown
outlines and one-cell ASCII fallbacks; the normal editor's LSP `K` mapping is unchanged.
A separate status/detail/all view keeps its own subscription while visible in the current tab; hiding it pauses
polling, and closing it releases the view; `q` closes it. Selection in
the all view follows provider/session identity. Root details expose backend
aggregate counters and own request IDs, not a reconstructed descendant tree.

Waiting counts with `+?` are lower bounds. Unknown attention and unknown semantic
states remain explicit; unknown liveness is not idle. A connection failure retains
old observations and marks transport health separately. Names and paths are
sanitized and display-width limited. Rows prefer a supplied name with cwd context,
then the cwd basename, then 名前なし; same-name or truncation collisions receive a
short session suffix. The currently pinned raw hooks supply cwd but not name, so
the UI does not promise automatically generated task titles. K/Enter retains the
full ID/cwd and shows the label source. Label changes do not affect sorting,
collection scope or cap allocation. Rendering never reads files or launches
processes in the mimori component.

Set `vim.g.mimori` before lazy loading Komado to override `binary`, `state_dir`
(absolute), `provider`, `interval`, `timeout`, `ensure_timeout`, `max_backoff`,
`max_stdout`, or `max_stderr`. Defaults are 2 s between completed polls, 1 s query
timeout, 6 s outer startup timeout, 30 s maximum retry backoff, 4 MiB stdout and
16 KiB stderr. These are adjustable PoC limits, not provider latency guarantees.
The default summary-row budget is 10 (`require('mimori.komado').setup({cap=10})`),
shared between providers and including uncertain-hierarchy entries. Allocation is
round-robin between provider groups, first for non-ended summaries and then for
ended history using spare slots; provider headers and overflow rows are extra.
Each provider keeps stable session-ID ordering within those two partitions.
Idle/unknown entries remain prioritized, and ended parents with running/waiting/unknown
aggregates remain prioritized. No history is deleted; the all view retains every
summary with the same ordering. See [actual sidebar previews and
notation](mimori-sidebar.md).

Generic API: `setup(opts)`, `subscribe(callback)` returning an idempotent release,
`snapshot()` (cached read-only value), `refresh()` (one request when unobserved),
`detail(provider, session_id, callback)` returning cancel, and `shutdown()`.
There is one summary scope/cache per editor; setup changes invalidate it and
cancel old callbacks. Lifecycle, summary, and detail calls share one serialized queue. Same-ID detail
calls coalesce per identity, while different visible detail/hover views retain their own
cancellation tokens; summary work cannot be starved by repeated detail requests. No client
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

## Provider の rename 名

新しい mimori は provider の名前を `title`、従来の作業名を `name` として分けて返す。
表示の優先順位は **rename 名 → 既存の作業名 → cwd の末尾 →「名前なし」**。
project 名は引き続き隣に表示し、元の作業名は詳細の `name` に残る。
名前が解除されれば次の snapshot で fallback に戻る。色・アイコン・並び順・
アクティブ優先配置・同名の ID suffix は状態と既存の規則を使う。

Claude Code は SessionStart / UserPromptSubmit の `session_title` を取り込む。
rename 後の次の通常プロンプト送信、または resume で反映される。
操作を止めたままの即時追随や transcript の走査は行わない。
既存 hook script は新しい mimori binary を呼べばよく、個人設定を自動変更しない。

Codex の名前取得は、既に稼働している互換 App Server の Unix socket がある
場合の opt-in。例えば Neovim の mimori 初期化前に以下を設定する。

```lua
vim.g.mimori = {
  codex_socket = "/absolute/path/to/existing-codex-app-server.sock",
}
```

環境変数 `MIMORI_CODEX_SOCKET` でも指定できる。Lua option を省略すると環境を
継承し、空文字を指定すると新規 daemon 起動時の取得を無効にする。
実際の socket は既存 Codex の `codex app-server daemon version` の出力で確認する。
この設定は新しく起動する mimori daemon の環境に渡される。`ensure` は既存
mimori daemon を置き換えないため、稼働中の daemon への反映は所有者が別途行う。

mimori は通常 query がある間だけ、既知・保持対象の session を30秒ごと最大16件
照合する。2秒以内の短時間接続で、Codex の起動・停止・resume、全会話の列挙は
行わない。子 thread は明示的な ID と返却された session ID の一致を確認する。
取得した名前は次の通常 polling（既定2秒）で反映する。件数が多い場合は複数回に
分かれる。socket 不在・旧契約・ID 不一致の場合は既存のラベルへ fallback する。
Codex cloud task や socket を公開しない単独 embedded instance はこの方式の対象外。
`MimoriStatus` の `Codex titles` で disabled / refreshing / ready / unavailable を確認できる。
名前の変更は activity、終了時刻、終了後5分の query 保持期限を変更しない。

この更新の `v2-mimori` pin は [mimori PR #2](https://github.com/ttak0422/mimori/pull/2)
を main に取り込んだ merge commit `1efa9a4754cc2962c5963aa7251fe3f89d9375df` に固定する。
既存の flake input と nixpkgs follows は維持する。PR head と merge commit の tree は
同一のため `narHash` は変わらず、`rev` と `lastModified` が更新される。
旧 mimori の応答に title がなくても従来表示を継続する。
