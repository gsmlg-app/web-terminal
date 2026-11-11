# ZMODEM (sz / rz) File Transfer — Design

Date: 2026-11-11
Status: approved in conversation, pending implementation plan

## Why

The app replaces iTerm on macOS. iTerm users routinely run `sz file` on a remote
server to download it, and `rz` to upload local files. In this app today, `sz`
dumps the raw protocol to the screen as garbage and `rz` hangs until Ctrl+C. The
user wants both to just work.

## Goals

- **`sz` (download):** running `sz <files>` in any terminal tab downloads the
  files the way a browser does.
- **`rz` (upload):** running `rz` opens the system file picker, and the chosen
  files are sent to the remote.
- Works in SSH tabs and local tabs. Both go through the same terminal plugin.
- Visible progress, cancellable, and a clear result for each transfer.

## Non-goals

- Mobile (iOS/Android) download UX. On those platforms, transfers are declined
  cleanly (see Behaviour) so the terminal never hangs. Full mobile support can
  come later.
- XMODEM/YMODEM, Kermit, or drag-and-drop upload.
- Resuming interrupted transfers.

## Anti-goals (failure even if it "works")

- Garbage printed to the terminal, or the shell left hung, after any transfer,
  cancel or failure.
- Normal terminal output that happens to contain bytes like `**\x18B0` gets
  swallowed or delayed. Only a real ZMODEM handshake starts a transfer.
- Silently overwriting an existing local file.
- The UI freezing during a large transfer.

## Behaviour (decided with the user)

### Download (`sz`)

- A new terminal setting, "Downloads (sz)", has two modes:
  - **Save to folder** (default). Files go straight into a preset folder with no
    prompt. The folder defaults to the system Downloads folder (`~/Downloads` on
    macOS) and can be changed in settings with a folder chooser.
  - **Ask where to save.** Each `sz` session opens a folder chooser once for all
    files in that session. Cancelling the chooser skips all offered files, and
    the remote `sz` reports them as skipped.
- **Name clashes:** if the destination file exists, save as `name (1).ext`,
  `name (2).ext` and so on, like a browser. Never overwrite.
- The remote file name is reduced to its last path component. Names that are
  empty, `.` or `..` become `download`. Path separators and NUL are not allowed.

### Upload (`rz`)

- The system file picker opens and allows several files.
- Each chosen file is offered to the remote in order.
- Cancelling the picker ends the session cleanly, so the remote `rz` exits with
  nothing received.

### Progress and result (Claude's call; the user accepted proposals generally)

- **While a transfer runs:** a compact panel docked at the bottom of that tab's
  terminal view shows:
  - direction (↓ download / ↑ upload);
  - current file name;
  - bytes done / total, with a progress bar when the total is known;
  - file N of M when known;
  - a Cancel button.
- **Download finished:** a snackbar says "Saved to `<path>`" with a
  "Show in Finder" action. That action uses `open -R <path>` on macOS; Linux and
  Windows open the containing folder. For several files, the snackbar names the
  folder and the count.
- **Upload finished:** a snackbar says "Uploaded N file(s)".
- **Cancel or failure:**
  - abort the ZMODEM session by sending the standard cancel sequence (8×CAN
    followed by 8×BS);
  - delete the partially written local file;
  - restore normal terminal I/O;
  - show a snackbar "Transfer cancelled" or "Transfer failed: `<reason>`".
- While a transfer is active, keyboard input to that tab is not sent to the
  remote, apart from Ctrl+C, which acts as Cancel.

### Platforms

- macOS is the primary target. The app is not sandboxed, so writing to the
  chosen folder needs no extra entitlements.
- Linux and Windows desktop use the same code path.
- On iOS and Android, an incoming ZMODEM session is answered with the cancel
  sequence and a one-line notice is written to the terminal:
  `ZMODEM transfers are not supported on this device`.

## Architecture constraints

- **Interception point.** Detection and multiplexing sit in
  `TerminalPlugin` (`app_widget/terminal_plugin`), on the raw
  `ExecutionSession.output` bytes, before the UTF-8 decoder that currently feeds
  `terminal.write`. Keyboard output (`terminal.onOutput` → `session.write`) goes
  through the same multiplexer so it can be held during a transfer.
- **Protocol engine.** Reuse `ZModemCore` from the existing `zmodem: ^0.0.6`
  dependency. Do not use xterm's `ZModemMux`; it has known gaps:
  - no cancel;
  - start detection only within a single chunk, so a handshake split across two
    reads is missed;
  - async handlers that are not awaited;
  - a commented-out flow control.

  Write a new multiplexer that fixes these. Keep it a pure-Dart class with no
  Flutter imports, so it is unit-testable against byte streams.
- **Handshake detection.** Match the ZRQINIT / ZRINIT hex headers
  (`**\x18B00` / `**\x18B01`) across chunk boundaries by keeping a short tail
  from the previous chunk. Normal output must pass through unchanged, and in the
  same chunk order, apart from at most that small held-back tail. The tail must
  be released on the next chunk or within one event-loop turn.
- **Flow control.** Keep `ackRead` semantics. Each output chunk is acked as
  soon as it has been processed, as today. Writing a received file must not
  build up an unbounded in-memory queue: write through to a file `IOSink`.
- **UI and services split.** File-system and dialog access sits behind an
  interface the plugin receives, so the multiplexer and transfer logic are
  testable with fakes. Covered operations: resolve the download directory, pick
  a directory, pick files, open a sink for a unique file name, delete a partial
  file, reveal in Finder.
- **Settings.** Add the download mode and download directory to the existing
  `terminal_settings` bloc, persisted the same way as
  `terminal_option_key_behavior` (vault key), and show them in
  `settings_section_terminal.dart`. Use `<pkg>: any` for workspace deps and
  `file_picker` / `path_provider` as already used in the workspace.
- **Localisation.** All new user-facing strings go in the `app_lib/locale` ARB
  files (en, zh, zh_Hans, zh_Hant, de), regenerated with `melos run gen-l10n`.
- **Verification.**
  - Unit tests drive the multiplexer with recorded or synthesised ZMODEM byte
    streams.
  - A macOS integration test runs the real `sz` / `rz` (lrzsz, available on the
    dev machine) in a local PTY tab, with fake file dialogs. It checks a
    byte-identical round trip, cancel, and that the terminal stays usable
    afterwards.

## Calls made by Claude (not explicitly decided by the user)

- **Progress UI:** a docked panel during transfers, plus a completion snackbar
  with "Show in Finder".
- **"Ask" mode:** chooses one folder per `sz` session, not one per file.
- **Name clashes:** browser-style `name (1).ext`; never overwrite.
- **Keyboard during a transfer:** blocked, except Ctrl+C, which cancels.
- **Mobile:** declined with a notice; full support is out of scope.
- **Engine:** our own multiplexer on `ZModemCore`, rather than xterm's
  `ZModemMux`.

- **Partial multi-file failure:** if a later file in a multi-file `sz` fails,
  files that already completed are kept; only the partial file is deleted.
- **Closing a tab mid-transfer:** counts as Cancel.
- **False starts:** a transfer starts only on a full, valid hex header
  (checksum included). If the remote doesn't answer within a timeout, abort and
  restore the terminal.
- **Upload pacing:** read the file in chunks and await `ExecutionSession.write`
  for each, so memory stays bounded.
- **Web-server terminal sessions:** the built-in web server
  (`app_lib/web_server`) opens shells without `TerminalPlugin`, so it is out of
  scope.
- **Integration test:** skipped when lrzsz is not installed.

## Known engine gaps (builder check)

`zmodem` 0.0.6's `ZModemCore` has gaps that real lrzsz traffic is likely to hit:

- it never verifies data-subpacket CRCs;
- it never sends ZACK for ZCRCQ/ZCRCW;
- while sending, it has no handlers for receiver replies such as ZRPOS (it
  throws);
- it does not recognise a remote cancel;
- it can throw on optional ZFILE header fields.

Plan for this: verify against real `sz`/`rz` early. Where it breaks, vendor
`zmodem` under `third_party/` with minimal fixes, following the repo convention
for modified packages. It is currently a dependency of `app_widget/xterm` only,
so vendoring means a workspace dependency override that also affects xterm.

## Left to the builder

- Exact widget layout of the progress panel and the snackbar copy beyond the
  strings above.
- How the services interface is injected into `TerminalPlugin` (constructor
  parameter or provider lookup at mount).
- Whether hard edge cases in `ZModemCore` need a small local patch:
  - first try to work within its API;
  - if it is truly broken for lrzsz, vendor it under `third_party/`, following
    the repo's convention for modified packages;
  - record that decision.
