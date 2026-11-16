# Native terminal clipboard integration

WebTerminal's native Flutter terminal can accept remote OSC 52 clipboard writes.
This applies to any application that emits OSC 52, including suitable Codex CLI,
Vim/Neovim and tmux configurations. It does not install clipboard tools on the
remote machine or change remote configuration.

## Enable and trust a session

1. In Settings → Terminal, enable **Allow remote clipboard writes**. The default
   is off. The preference is stored with ordinary terminal settings, separately
   from credentials.
2. Open an interactive terminal session. In the top bar's **Terminal clipboard
   and selection** menu, choose **Trust this session for clipboard writes**.
   The terminal context menu provides the same action.
3. Run the clipboard test below. Choose **Revoke this session's clipboard access**
   to stop allowing writes in that session.

Connecting to a host, accepting an SSH host key, or restoring a saved tab does
not grant clipboard trust. Each new/reconnected shell starts untrusted. Closing,
exiting or disconnecting a session revokes its trust and drops queued clipboard
work. Disabling the global setting blocks writes immediately; per-session trust
otherwise lasts until revoked or the connection ends. Trust authorizes all
processes producing output in that session, including commands whose output you
print. An OS clipboard operation already dispatched cannot be recalled.

## Supported operations and security policy

| Input | Behavior |
| --- | --- |
| `ESC ] 52 ; c ; BASE64 BEL` | Write UTF-8 text to the local system clipboard |
| The same sequence ending in `ESC \` (ST) | Same behavior |
| Empty selection (`52;;...`) | Use the system clipboard |
| Empty payload | Clear the clipboard to an empty string |
| Payload `?` (clipboard query) | Ignore; never read the clipboard or reply |
| Other selection targets, extra arguments, malformed Base64 or invalid UTF-8 | Ignore |
| Decoded payload larger than 100 KiB (102400 bytes) | Ignore |
| Writes disabled, no active interactive session, or untrusted session | Ignore |
| Flutter Clipboard API failure | Discard that write; keep the terminal running |

Only the standard Base64 alphabet and up to two trailing padding characters are
accepted. The decoder also accepts valid unpadded Base64. Size is checked before
Base64 decoding and again on the decoded bytes. Clipboard contents are never
logged. The remote-write component has no clipboard-read API or SSH-write API.
Local clipboard contents are sent to a session only by an explicit native Paste
menu action or paste shortcut.

Clipboard writes run asynchronously, outside output parsing. A slow OS clipboard
does not pause SSH reads, acknowledgments, input or rendering. Writes are
serialized with at most one waiting update; when several arrive while busy, the
newest pending value replaces older pending values. Revocation and session
changes invalidate pending work. The parser caps OSC/DCS/SOS/PM/APC bodies at
256 Ki UTF-16 code units and discards an overflowing string until termination or
cancellation, bounding incomplete control-string storage. The 100 KiB clipboard
limit is independent of this parser limit.

## Native selection and paste

Native text selection is independent of OSC 52 authorization. Copy, Paste and
Select All remain available when remote writes are disabled.

- Drag or double-click to select ordinary terminal text. Use Copy in the native
  top-bar menu or terminal context menu.
- On macOS, use Cmd+C / Cmd+V / Cmd+A. On Linux and Windows, use Ctrl+Shift+C /
  Ctrl+Shift+V / Ctrl+Shift+A. The existing Ctrl+V and Ctrl+A aliases remain.
  Ctrl+C continues to send the terminal interrupt character.
- When an application enables mouse reporting, ordinary clicks and drags still
  reach that application. Hold Option/Alt while selecting to force local
  selection. Option/Alt+right-click opens the native context menu in this mode.
- Alternatively, enable **Select text (pause mouse reporting)** in the native
  menu. Disable it to resume application mouse interaction. This uses the
  terminal controller's pointer suspension; it does not send mouse-mode changes
  to the remote application. Scrollback is retained.
- Native Paste goes through `Terminal.paste`, retaining line-ending conversion
  and bracketed-paste handling. OSC 52 does not synthesize keyboard input.

The top-bar menu is outside the terminal surface and does not cover terminal
cells. If the top bar is hidden in fullscreen, restore navigation to access it;
Option/Alt selection and the desktop context menu remain available.

## Architecture and audit findings

The application uses the workspace fork of **xterm.dart 4.0.0** in
`app_widget/xterm`, not xterm.js, xterm2 or a browser clipboard implementation.
There is also a separate browser terminal client; this change targets the native
Flutter terminal.

```mermaid
flowchart LR
  A[Remote application] --> B[SSH PTY bytes]
  B --> C[Shell PID filter]
  C --> D[ExecutionSession.output]
  D --> E[ZMODEM detection]
  E --> F[Chunked UTF-8 decoder]
  F --> G[xterm EscapeParser]
  G --> H[Terminal.onPrivateOSC]
  H --> I[RemoteClipboard policy]
  I --> J[Flutter Clipboard.setData]
  J --> K[Local OS clipboard]
```

The original parser already recognized OSC, BEL/ST termination and fragmented
sequences, forwarding unknown OSCs through `Terminal.onPrivateOSC`. The actual
missing integration was in `TerminalPlugin.didMounted`: its callback handled
only OSC 7 working-directory events, silently ignoring OSC 52. Native Copy and
Paste already used Flutter's `Clipboard` API, but those selection actions do not
handle remote clipboard requests.

The SSH layer forwards channel stdout as bytes. Its shell wrapper strips only
its own initial `OSC 1337;WebTerminalShellPid=...` marker. ZMODEM detection passes
ordinary output to a stateful `Utf8Decoder(allowMalformed: true)`. Neither layer
contains an OSC 52 filter. Tests exercise the session stream, ZMODEM path,
UTF-8 decoder, terminal batching, parser, policy, and Flutter clipboard channel,
including one-byte chunks. SSH and shell-filter regressions check their own
boundaries separately.

The existing parser is reused; no clipboard escape scanner was added to SSH.
Its OSC/control-string consumption now streams without reparsing the entire
unfinished string on each chunk. It also consumes supported tmux envelopes,
rejects cancelled/malformed strings, and caps retained bodies. Other ANSI and
OSC handlers still use the same dispatch paths. Changing interactive sessions
discards incomplete parser input and queued batched output, preserving rendered
history so an old session cannot finish a command in a new session.

`RemoteClipboard` owns decoding, size checks, session trust and asynchronous
writes; its writer can be injected for tests. `TerminalPlugin` owns interactive
session lifecycle and supplies the existing OSC callback. The application reads
the current global policy through a callback, so it also applies to inactive
terminal tabs without relying on their widget rebuilds. Native top-bar and
context-menu actions share selection copy/paste helpers.

SSH PTYs request `xterm-256color` with the terminal's dimensions and propagate
resizes. WebTerminal does not add a Codex-specific terminal identity or clipboard
environment variable. The terminal plugin opens SSH shells without an explicit
custom environment map. The server supplies ordinary SSH session variables;
remote applications and terminfo decide whether to emit OSC 52. A complete
clipboard path therefore also requires the remote application to emit it.

## tmux

Test direct SSH first. tmux can forward or suppress application OSC 52 before
WebTerminal sees it. Inspect the running server rather than assuming a config
file was loaded:

```sh
tmux show -s set-clipboard
tmux info | grep 'Ms:'
tmux display-message -p '#{client_termname} #{client_termfeatures}'
```

For tmux's native clipboard forwarding, a typical configuration is:

```tmux
set -s set-clipboard on
# If tmux does not detect the outer terminal's clipboard capability:
set -as terminal-features ',xterm-256color:clipboard'
```

`set-clipboard external` permits tmux's own copying but does not accept clipboard
writes from applications inside tmux. `on` allows both; the local WebTerminal
policy still applies. The `terminal-features` option requires a sufficiently
recent tmux. With older versions, consult that version's terminfo/`Ms`
configuration rather than copying an unrelated application's terminal overrides.

For programs emitting tmux DCS passthrough, supported tmux versions may also
require:

```tmux
set -g allow-passthrough on
```

WebTerminal accepts one standard `ESC P tmux; ... ESC \` envelope containing
exactly one OSC 52 command, with each inner ESC doubled. The inner command may
use BEL or ST. It goes through the existing OSC parser and the same local
security checks. Other passthrough commands and recursively nested envelopes
are not enabled. Prefer native forwarding at each hop in nested tmux sessions.

These settings are recommendations to review and apply manually. WebTerminal
never edits NixOS, macOS or tmux configuration. Automated tests cover the emitted
bytes, including fragmented passthrough envelopes; a live tmux server has not
been validated in this change.

## Reproduce and diagnose

On a directly connected NixOS or macOS SSH host, after enabling the setting and
trusting the session:

```bash
printf '\033]52;c;%s\a' \
  "$(printf 'webterminal-osc52-test' | base64 | tr -d '\n')"
```

Paste into a local text application. Expect `webterminal-osc52-test`. To check ST:

```bash
printf '\033]52;c;%s\033\\' \
  "$(printf 'webterminal-osc52-st-test' | base64 | tr -d '\n')"
```

If direct SSH works but tmux does not, check the tmux options above and repeat
inside tmux. If this test works but Codex or Vim/Neovim copying does not, verify
that application's documented OSC 52 clipboard configuration and emitted
protocol. Check `printf '%s\n' "$TERM" "$TMUX"` and, where available,
`infocmp "$TERM"`. Avoid recording clipboard payloads or dumping session output
containing private data into diagnostics.

For manual acceptance, repeat on both remote OSes: the direct printf test,
Codex copy and ordinary input/fullscreen/mouse interaction, native selection and
Copy, local Paste, and Vim/Neovim OSC 52 copying. Then repeat the clipboard tests
inside tmux. Reconnect and confirm that explicit trust is required again.

## Verification and limits

Focused automated tests cover the native Flutter clipboard method channel and an
injected clipboard writer; BEL/ST; arbitrary fragmentation; Unicode/multiline
and empty text; invalid, cancelled and oversized input; read denial; disabled
and untrusted policy; API failures; bounded asynchronous writes and revocation;
session boundaries; tmux envelopes; selection, shortcuts and bracketed paste.
Desktop widget tests simulate macOS, Linux and Windows key mappings. They do not
prove OS clipboard behavior on those three operating systems.

The full xterm suite also includes an existing `htop golden test` failure in the
local Flutter 3.47.9 environment (2 pixels differ). Running that test with the
original parser and terminal sources from the pre-change commit reproduced the
same failure. The golden baseline has not been changed.

Real NixOS/macOS SSH sessions, live Codex CLI and Vim/Neovim copies, and live tmux
were not exercised during implementation. Native OS clipboard integration on
each supported Flutter device platform remains a manual validation item. The
native API has no platform-specific command dependency, but availability still
depends on the OS/Flutter clipboard implementation. Browser clipboard permission
and embedding behavior belong to the separate browser client and are outside
this change.
