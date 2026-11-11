# ZMODEM (sz / rz) Transfer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Running `sz` in a terminal tab downloads files like a browser does. Running `rz` opens a file picker and uploads the chosen files. Both show progress, can be cancelled, and leave the terminal clean.

**Architecture:**
- A pure-Dart `ZmodemTransferController` (in `terminal_plugin`) sits between `ExecutionSession` bytes and the xterm `Terminal`. It passes ordinary output through. It detects a real ZMODEM handshake across chunk boundaries, then drives a vendored, fixed `ZModemCore`.
- File-system and dialog access sit behind `ZmodemFileAccess`.
- `TerminalPlugin` owns one controller per session. `TerminalTabView` shows a progress panel and result snackbars.
- Download settings live in the existing `terminal_settings` bloc.

**Tech Stack:** Flutter 3.47, Dart, `zmodem` 0.0.6 (vendored to `third_party/zmodem`), `file_picker` 13.1.0, `path_provider`, flutter_bloc, lrzsz (`sz`/`rz`, at `/run/current-system/sw/bin`) for interop tests.

**Spec:** `docs/superpowers/specs/2026-11-11-zmodem-transfer-design.md`

## Global Constraints

- **Interception:** on raw `ExecutionSession.output` bytes in `TerminalPlugin`, before UTF-8 decoding. Keyboard output also goes through the controller.
- **Starting a transfer:** only a full, valid ZRQINIT/ZRINIT hex header (CRC checked) starts one. Ordinary output passes through unchanged and in order. At most a short held-back tail is delayed, and it is released on the next chunk or within one event-loop turn.
- **Downloads:**
  - Never overwrite. Use browser-style `name (1).ext`, `name (2).ext`.
  - Reduce the remote name to its last path component. Empty, `.`, `..` → `download`. No separators or NUL.
- **Cancel or failure:**
  - Send 8×CAN (0x18) followed by 8×BS (0x08).
  - Delete the partial file; keep completed files.
  - Restore terminal I/O.
  - Results: `Transfer cancelled` / `Transfer failed: <reason>`.
- **During a transfer:** keyboard input is not sent to the remote. Ctrl+C (0x03) cancels. Closing the tab cancels.
- **Download settings:**
  - Mode `saveToFolder` (default) or `ask`.
  - The folder defaults to the system Downloads folder.
  - In `ask` mode, pick one folder per `sz` session. Cancelling the picker skips all offered files.
- **Upload:** a multi-file picker. Cancelling it ends the session cleanly, so `rz` exits.
- **iOS/Android:** answer every handshake with the cancel sequence and write `ZMODEM transfers are not supported on this device` to the terminal.
- **Panel:** shows ↓/↑, file name, bytes done/total, a bar when the total is known, `N of M` when known, and Cancel.
- **Snackbars:**
  - `Saved to <path>` for one file, or the folder and count for several, with `Show in Finder` (macOS `open -R <path>`; Linux/Windows open the folder).
  - `Uploaded N file(s)`.
- **Persistence:** vault keys `terminal_download_mode` and `terminal_download_directory`, the same pattern as `terminal_option_key_behavior` in `app_bloc/terminal_settings/lib/src/bloc.dart`.
- **Strings:** all new user-facing strings in the `app_lib/locale` ARB files (en, zh, zh_Hans, zh_Hant, de), regenerated with `melos run gen-l10n`.
- **Dependencies:** `<pkg>: any` for workspace deps. Format only touched files.
- **Git:** work on `main`. Commit only when the user authorises it. No Claude attribution lines.

## Review Focus

1. **A large download (≥ 50 MB) over SSH:** memory stays bounded and the UI responsive. Data is written through an `IOSink` and acked per chunk, with no unbounded buffering. Covered in Task 3 by `download of 8 MB completes with bounded buffering`.
2. **A command that prints the raw handshake bytes**, e.g. `cat` of a file containing `**\x18B00` with a wrong CRC: no transfer starts and the bytes appear in the terminal. Covered in Task 3 by `invalid header text passes through`.
3. **The remote side dies mid-transfer** (`kill` the sz, or the SSH connection drops): the transfer fails, the partial file is deleted, and the terminal is usable. Covered in Task 3 by `remote cancel mid-download` and `session ends mid-download`.
4. **Multi-file `sz` where file 2 already exists locally:** saved as `name (1).ext`, and file 1 is unaffected. Covered in Task 2 by `uniqueFileName` and in Task 3 by `multi-file download with clash`.
5. **UTF-8 text split across output chunks** (e.g. Chinese characters at a chunk edge): it still renders correctly now that decoding happens after the controller. Covered in Task 5 by `utf8 split across chunks renders intact`.

---

## File Structure

| File | Responsibility |
|---|---|
| `third_party/zmodem/` (vendored from pub 0.0.6) | Protocol core with fixes: CRC check, ZACK, ZRPOS while sending, remote cancel, tolerant ZFILE fields. |
| `app_widget/terminal_plugin/lib/src/zmodem/zmodem_file_access.dart` | `ZmodemFileAccess` interface, `ZmodemLocalFile`, `ZmodemDownloadTarget`, `sanitizeRemoteFileName`, `uniqueFileName`. |
| `app_widget/terminal_plugin/lib/src/zmodem/io_zmodem_file_access.dart` | dart:io + file_picker + path_provider implementation. |
| `app_widget/terminal_plugin/lib/src/zmodem/zmodem_transfer_controller.dart` | Handshake detection, passthrough, transfer state machine, progress, results, cancel. |
| `app_widget/terminal_plugin/lib/src/zmodem/zmodem_progress_panel.dart` | Progress panel widget. |
| `app_widget/terminal_plugin/lib/src/terminal_plugin.dart` | Wiring, snackbars. |
| `app_bloc/terminal_settings/lib/src/{state,event,bloc}.dart` | Download mode and directory. |
| `app_widget/terminal_settings/lib/src/settings_section_terminal.dart` | Settings tiles. |
| `lib/screens/terminal/terminal_screen.dart` | Passes the settings-backed `IoZmodemFileAccess` into `TerminalPlugin`. |
| `integration_test/zmodem_transfer_test.dart` | Real sz/rz in a local PTY on macOS. |

---

### Task 1: Vendor `zmodem` and make it interoperate with lrzsz

**Files:**
- Create: `third_party/zmodem/` (copy of `/Users/gao/.local/share/pub-cache/hosted/pub.dev/zmodem-0.0.6`, keeping LICENSE).
  - Its `pubspec.yaml` gets `resolution: workspace`, `publish_to: none`, version `0.0.6`.
  - Add a `README` note listing the local fixes.
- Modify:
  - root `pubspec.yaml` workspace list: add `third_party/zmodem`;
  - `app_widget/xterm/pubspec.yaml`: `zmodem: any`;
  - `third_party/zmodem/lib/core.dart`, `lib/src/zmodem_event.dart`, `lib/src/zmodem_parser.dart`.
- Test: `third_party/zmodem/test/lrzsz_interop_test.dart`, `third_party/zmodem/test/core_fixes_test.dart`

**Interfaces:**
- Produces, used by Task 3:
  - The existing `ZModemCore` API, unchanged: `receive(Uint8List)`, `dataToSend()`, `initiateSend()`, `initiateReceive()`, `acceptFile([int])`, `skipFile()`, `offerFile(ZModemFileInfo)`, `sendFileData(Uint8List)`, `finishSending(int)`, `finishSession()`.
  - New events in `zmodem_event.dart`:
    - `ZSessionCancelledEvent` (remote sent ≥5 CAN);
    - `ZFileRepositionEvent(int offset)` (ZRPOS while sending).
  - `receive` throws `ZModemException` on a data-subpacket CRC mismatch.
  - The receiver auto-enqueues ZACK when a subpacket ends in ZCRCQ/ZCRCW.
  - ZACK received while sending is ignored.
  - Unparseable optional ZFILE fields (size/mtime/mode) are treated as absent (`null`) instead of throwing.

- [ ] **Step 1: Write the interop tests (real lrzsz over pipes).** Skip the whole file if `which sz` fails.
  - `receives a file from sz byte-identically`:
    1. Create a 300 KB file of random bytes, plus every byte 0x00–0xFF repeated.
    2. `Process.start('sz', ['--binary', path])`.
    3. Feed its stdout to `ZModemCore.receive`; on `ZFileOfferedEvent`, `acceptFile(0)`.
    4. Write `dataToSend()` to stdin, collect the `ZFileDataEvent` bytes, finish on `ZSessionFinishedEvent`.
    5. Expect the bytes to equal the source, `fileInfo.pathname` to be the base name, `fileInfo.length == 300 * 1024 + 256 * 4`, and the process to exit with code 0.
  - `sends a file to rz byte-identically`:
    1. Run `Process.start('rz', ['--binary'], workingDirectory: tmpDir)`.
    2. `initiateSend()`; on `ZReadyToSendEvent`, `offerFile(ZModemFileInfo(pathname: 'up.bin', length: n))`.
    3. On `ZFileAcceptedEvent(offset)`, send chunks of 8 KB with `sendFileData` + `dataToSend()`, then `finishSending(n)`.
    4. On the next `ZReadyToSendEvent`, `finishSession()`.
    5. Expect `tmpDir/up.bin` to equal the source and rz to exit with code 0.
  - `sz of two files delivers both`.

- [ ] **Step 2: Write the fix unit tests** (`core_fixes_test.dart`), building frames with the package's own `ZModemHeader` / data subpacket encoders:
  - `CRC mismatch in a data subpacket throws ZModemException`;
  - `ZCRCQ subpacket makes the receiver enqueue ZACK with the current offset`;
  - `five CAN bytes yield ZSessionCancelledEvent` (in any state);
  - `ZRPOS while sending yields ZFileRepositionEvent(offset)`;
  - `ZFILE header with garbage size field parses with length null`.

- [ ] **Step 3: Run them and confirm they fail.**
  - Run: `cd third_party/zmodem && dart test`
  - Expected: the fix tests fail. Record in the ledger which interop tests fail, if any.

- [ ] **Step 4: Implement the fixes** in `core.dart` / `zmodem_parser.dart` / `zmodem_event.dart`, using the smallest change that passes. Use the CRC16/CRC32 already in `src/crc.dart` for the data subpacket check.

- [ ] **Step 5: Run the tests.**
  - Run: `cd third_party/zmodem && dart test && cd ../../app_widget/xterm && flutter test`
  - Expected: all pass.

- [ ] **Step 6: Commit** (if authorised): `fix(zmodem): vendor zmodem and fix lrzsz interop`

---

### Task 2: File access abstraction and IO implementation

**Files:**
- Create: `app_widget/terminal_plugin/lib/src/zmodem/zmodem_file_access.dart`, `.../io_zmodem_file_access.dart`
- Modify: `app_widget/terminal_plugin/pubspec.yaml`: add `file_picker: ^13.1.0`, `path_provider: any` (matching the version already in the lock), `zmodem: any`.
- Test: `app_widget/terminal_plugin/test/zmodem/zmodem_file_access_test.dart`

**Interfaces:**
- Produces, used by Tasks 3, 5 and 6:
  ```dart
  enum ZmodemDownloadMode { saveToFolder, ask }

  class ZmodemLocalFile {
    const ZmodemLocalFile({required this.path, required this.name, required this.length});
    final String path; final String name; final int length;
    Stream<List<int>> read([int start = 0]);   // File(path).openRead(start)
  }

  class ZmodemDownloadTarget {
    ZmodemDownloadTarget(this.path, this.sink);
    final String path; final IOSink sink;
    Future<void> complete();   // flush + close
    Future<void> discard();    // close + delete file, ignoring errors
  }

  abstract interface class ZmodemFileAccess {
    /// Folder for this sz session; null when the user cancelled the folder picker.
    Future<String?> resolveDownloadDirectory();
    /// Files to upload; null or empty when the user cancelled.
    Future<List<ZmodemLocalFile>?> pickUploadFiles();
    Future<ZmodemDownloadTarget> createDownload(String directory, String remoteName);
    Future<void> reveal(String path);
  }

  String sanitizeRemoteFileName(String remoteName);
  String uniqueFileName(String directory, String fileName, bool Function(String path) exists);

  class IoZmodemFileAccess implements ZmodemFileAccess {
    IoZmodemFileAccess({required ({ZmodemDownloadMode mode, String? directory}) Function() settings});
  }
  ```
- `IoZmodemFileAccess` behaviour:
  - `saveToFolder`: use the `directory` setting, or `getDownloadsDirectory()`, or `$HOME/Downloads`.
  - `ask`: `FilePicker.getDirectoryPath()`.
  - Uploads: `FilePicker.pickFiles(allowMultiple: true)`, keeping entries with a non-null `path`.
  - `createDownload`: `File(join(dir, uniqueFileName(dir, sanitizeRemoteFileName(name), exists))).openWrite()`.
  - `reveal`:
    - macOS: `Process.run('open', ['-R', path])`;
    - Linux: `xdg-open <dir>`;
    - Windows: `explorer /select,<path>`.

- [ ] **Step 1: Write the failing tests.**
  - `sanitizeRemoteFileName`:
    - `'dir/sub/a.txt'` → `'a.txt'`
    - `'..'` → `'download'`
    - `''` → `'download'`
    - `'a\u0000b'` → `'ab'`
    - `'C:\\x\\y.bin'` → `'y.bin'`
  - `uniqueFileName`: when `a.txt` and `a (1).txt` exist, it returns `'a (2).txt'`. When `archive.tar.gz` exists, it returns `'archive.tar (1).gz'`. No extension: `'Makefile (1)'`.
  - `IoZmodemFileAccess` with a temp dir in `saveToFolder` mode:
    - `resolveDownloadDirectory()` returns that dir;
    - `createDownload(dir, 'x.bin')` twice gives paths ending in `x.bin` and `x (1).bin`;
    - `discard()` removes the file and `complete()` keeps it.

- [ ] **Step 2: Run and confirm failure.**
  - Run: `cd app_widget/terminal_plugin && flutter test test/zmodem/zmodem_file_access_test.dart`
  - Expected: compile error.

- [ ] **Step 3: Implement** both files.

- [ ] **Step 4: Run.** Same command. Expected: pass.

- [ ] **Step 5: Commit** (if authorised): `feat(terminal): add zmodem file access`

---

### Task 3: `ZmodemTransferController`

**Files:**
- Create: `app_widget/terminal_plugin/lib/src/zmodem/zmodem_transfer_controller.dart`
- Test:
  - `app_widget/terminal_plugin/test/zmodem/zmodem_transfer_controller_test.dart` (fake peer built from a second `ZModemCore`)
  - `app_widget/terminal_plugin/test/zmodem/zmodem_lrzsz_test.dart` (real `sz`/`rz` over pipes, skipped without lrzsz)

**Interfaces:**
- Consumes `ZModemCore` and the new events (Task 1), and `ZmodemFileAccess` and friends (Task 2).
- Produces, used by Task 5:
  ```dart
  enum ZmodemDirection { download, upload }

  @immutable
  class ZmodemProgress {
    const ZmodemProgress({required this.direction, required this.fileName, required this.bytesDone, this.totalBytes, required this.fileIndex, this.fileCount});
    final ZmodemDirection direction; final String fileName; final int bytesDone; final int? totalBytes; final int fileIndex; final int? fileCount;
  }

  sealed class ZmodemTransferResult {}
  final class ZmodemDownloadCompleted extends ZmodemTransferResult { ZmodemDownloadCompleted(this.paths); final List<String> paths; }
  final class ZmodemUploadCompleted extends ZmodemTransferResult { ZmodemUploadCompleted(this.count); final int count; }
  final class ZmodemTransferCancelled extends ZmodemTransferResult {}
  final class ZmodemTransferFailed extends ZmodemTransferResult { ZmodemTransferFailed(this.reason); final String reason; }

  class ZmodemTransferController {
    ZmodemTransferController({
      required void Function(Uint8List bytes) onTerminalOutput,
      required Future<void> Function(Uint8List bytes) writeToSession,
      required ZmodemFileAccess files,
      bool supported = true,
      Duration handshakeTimeout = const Duration(seconds: 10),
    });
    void handleSessionOutput(Uint8List chunk);
    /// Returns true when [bytes] were consumed by an active transfer (not sent to the remote).
    bool handleKeyboardInput(Uint8List bytes);
    ValueListenable<ZmodemProgress?> get progress;   // null when idle
    Stream<ZmodemTransferResult> get results;
    bool get isActive;
    Future<void> cancel();
    Future<void> dispose();   // cancels an active transfer
  }
  ```
- **Detection:** search the concatenation of the previous ≤ 20-byte tail and the new chunk for `**\x18B0`. Then require the full hex header (frame type ZRQINIT 0x00 or ZRINIT 0x01, CRC16 valid, followed by CR LF / CR LF XON). Bytes before the header go to `onTerminalOutput`. An incomplete potential header is held back. A `Timer.run` flushes a held tail if no chunk follows.
- **Downloads:**
  - Resolve the directory once per session; `null` → `skipFile` for every offer.
  - On each `ZFileOfferedEvent`, `createDownload` and `acceptFile(0)`.
  - Write data to the target sink.
  - `ZFileEndEvent` → `complete()`.
  - On `ZSessionFinishedEvent`, emit `ZmodemDownloadCompleted(paths)` if any file completed, otherwise `ZmodemTransferCancelled`.
- **Uploads:**
  - On `ZReadyToSendEvent` the first time, `pickUploadFiles()`. Null or empty → `finishSession()` and emit `ZmodemTransferCancelled`.
  - Offer each file. On accept, stream `read(offset)` in chunks, awaiting `writeToSession` for each.
  - On `ZFileRepositionEvent(o)`, restart from `o`.
  - When done, emit `ZmodemUploadCompleted(count)`.
- **Cancel:**
  - Write `[0x18 ×8, 0x08 ×8]`.
  - `discard()` the current download.
  - Reset to passthrough and emit `ZmodemTransferCancelled`.
  - Remote cancel, a `ZModemException`, a handshake timeout or session end → the same cleanup, but emit `ZmodemTransferFailed(reason)`.
- **Keyboard:** while active, return true for all input and treat 0x03 as `cancel()`. While idle, return false.
- **Unsupported:** on a valid handshake, write the cancel sequence, call `onTerminalOutput` with `'\r\nZMODEM transfers are not supported on this device\r\n'`, and stay in passthrough.

- [ ] **Step 1: Write the failing controller tests** (fake peer: a `ZModemCore` acting as the remote, wired through in-memory callbacks; fake `ZmodemFileAccess` over a temp dir):
  - `plain output passes through unchanged`: three chunks of mixed text and UTF-8 bytes come out byte-equal and in order.
  - `handshake split across chunks starts a download`: split the sender's first `dataToSend()` at each byte offset 1..len-1.
  - `invalid header text passes through`: `'**\x18B00' + 'ffffffffffffff\r\n'` with a bad CRC is emitted to the terminal; `isActive` is false.
  - `download writes the file and reports completion`: one file, `results` emits `ZmodemDownloadCompleted([tmp/a.bin])`, and the contents are equal.
  - `multi-file download with clash`: with `b.txt` pre-existing, sending `a.txt` and `b.txt` gives paths `[a.txt, b (1).txt]`.
  - `ask mode cancelled skips every file`: `resolveDownloadDirectory` returns null, the peer gets skips, the result is `ZmodemTransferCancelled`, and no files are written.
  - `upload sends picked files`: the peer receives an identical file and the result is `ZmodemUploadCompleted(1)`.
  - `upload picker cancelled ends the session`: the result is `ZmodemTransferCancelled` and the peer sees the session finish.
  - `cancel mid-download sends the abort sequence and deletes the partial file`: written bytes end with 8×0x18 then 8×0x08, the file is gone, and `isActive` is false.
  - `remote cancel mid-download`: the peer sends 5×CAN, the result is `ZmodemTransferFailed`, and the partial file is gone.
  - `session ends mid-download`: `dispose()` deletes the partial file.
  - `keyboard is held during a transfer and Ctrl+C cancels`.
  - `handshake timeout restores passthrough`: with `handshakeTimeout: 50ms` and a peer that never answers, the result is `ZmodemTransferFailed` and later plain output passes through.
  - `unsupported device declines with a notice`.
  - `download of 8 MB completes with bounded buffering`: the bytes held in the controller never exceed 1 MB at any point. Assert via a debug getter `@visibleForTesting int get bufferedBytes`.

- [ ] **Step 2: Write the lrzsz tests** (`zmodem_lrzsz_test.dart`), driving the controller with `Process.start` pipes for `sz --binary f1 f2` and `rz --binary`. Expect identical files, exit code 0, and `cancel()` during a 20 MB `sz` to make sz exit non-zero within 5 s, with no leftover partial file.

- [ ] **Step 3: Run them and confirm they fail.**
  - Run: `cd app_widget/terminal_plugin && flutter test test/zmodem/`
  - Expected: compile error.

- [ ] **Step 4: Implement the controller.**

- [ ] **Step 5: Run.** Same command. Expected: all pass.

- [ ] **Step 6: Commit** (if authorised): `feat(terminal): add zmodem transfer controller`

---

### Task 4: Download settings and strings

**Files:**
- Modify:
  - `app_bloc/terminal_settings/lib/src/state.dart`: `TerminalSettingsLoaded` gains `final TerminalDownloadMode downloadMode` (default `saveToFolder`) and `final String? downloadDirectory`, with `copyWith`.
  - `event.dart`: `TerminalSettingsUpdateDownloadMode({required TerminalDownloadMode downloadMode})` and `TerminalSettingsUpdateDownloadDirectory({required String? downloadDirectory})`.
  - `bloc.dart`: load and save under `terminal_download_mode` / `terminal_download_directory`. A null directory deletes the key.
  - `app_widget/terminal_settings/lib/src/settings_section_terminal.dart`: two tiles, desktop only. One is a mode dropdown (key `downloadModeDropdown`). The other shows the folder path or "System Downloads", with "Choose…" (`FilePicker.getDirectoryPath`) and "Reset" (key `downloadDirectoryTile`).
  - The ARB files, then `melos run gen-l10n`.
- Test: `app_bloc/terminal_settings/test/terminal_settings_bloc_test.dart`, `app_widget/terminal_settings/test/settings_section_terminal_test.dart`

**Interfaces:**
- Produces `enum TerminalDownloadMode { saveToFolder, ask }` (in `terminal_settings_bloc`). Task 5 maps it to `ZmodemDownloadMode` by name.
- l10n keys used by Tasks 4 and 5:

  | Key | en | zh_Hans |
  |---|---|---|
  | `zmodemDownloads` | Downloads (sz) | 下载 (sz) |
  | `zmodemDownloadModeFolder` | Save to folder | 保存到文件夹 |
  | `zmodemDownloadModeAsk` | Ask where to save | 每次询问保存位置 |
  | `zmodemDownloadFolder` | Download folder | 下载文件夹 |
  | `zmodemSystemDownloads` | System Downloads | 系统下载文件夹 |
  | `zmodemChooseFolder` | Choose… | 选择… |
  | `zmodemReset` | Reset | 重置 |
  | `zmodemCancel` | Cancel | 取消 |
  | `zmodemSavedTo(path)` | Saved to {path} | 已保存到 {path} |
  | `zmodemSavedFiles(count, folder)` | {count, plural, =1{Saved 1 file to {folder}} other{Saved {count} files to {folder}}} | 已保存 {count} 个文件到 {folder} |
  | `zmodemUploaded(count)` | {count, plural, =1{Uploaded 1 file} other{Uploaded {count} files}} | 已上传 {count} 个文件 |
  | `zmodemCancelled` | Transfer cancelled | 传输已取消 |
  | `zmodemFailed(reason)` | Transfer failed: {reason} | 传输失败：{reason} |
  | `zmodemShowInFinder` | Show in Finder | 在访达中显示 |
  | `zmodemFileOf(index, count)` | {index} of {count} | 第 {index}/{count} 个 |

  The zh and zh_Hant entries mirror zh_Hans (zh_Hant in traditional script). de gets German. The unsupported-device notice stays English because it is terminal text.

- [ ] **Step 1: Write the failing tests.**
  - Bloc:
    - `loads download mode and directory from vault`;
    - `UpdateDownloadMode persists terminal_download_mode`;
    - `UpdateDownloadDirectory(null) deletes the key`.
  - Widget, with macOS as the target platform:
    - `download tiles show mode and System Downloads by default`;
    - `choosing ask mode dispatches UpdateDownloadMode`;
    - `download tiles hidden on iOS`.
- [ ] **Step 2: Run and confirm failure.**
  - Run: `melos exec --scope terminal_settings_bloc,terminal_settings -- flutter test`
  - Expected: compile errors.
- [ ] **Step 3: Implement** the state, events, bloc, tiles and ARB entries, then run `melos run gen-l10n`.
- [ ] **Step 4: Run.** Same command plus `melos run analyze`. Expected: pass.
- [ ] **Step 5: Commit** (if authorised): `feat(settings): add sz download settings`

---

### Task 5: Wire into `TerminalPlugin` with panel and snackbars

**Files:**
- Modify:
  - `app_widget/terminal_plugin/lib/src/terminal_plugin.dart`;
  - `lib/screens/terminal/terminal_screen.dart` (`_createTerminalPlugin` passes `fileAccess`).
- Create: `app_widget/terminal_plugin/lib/src/zmodem/zmodem_progress_panel.dart`
- Test: `app_widget/terminal_plugin/test/zmodem/terminal_plugin_zmodem_test.dart`

**Interfaces:**
- Consumes Tasks 2–4.
- `TerminalPlugin({..., ZmodemFileAccess? fileAccess})`.
- Exposes `@visibleForTesting ZmodemTransferController? get zmodem` for the current session.
- `ZmodemProgressPanel({required ZmodemProgress progress, required VoidCallback onCancel})`, with key `zmodem-progress-panel` and a Cancel button keyed `zmodem-cancel`.
- `terminal_screen.dart` builds `IoZmodemFileAccess(settings: () => (mode: ZmodemDownloadMode.values.byName(s.downloadMode.name), directory: s.downloadDirectory))` from `TerminalSettingsBloc` state.

**Behaviour:**
- **Connect:** in `didConnected`, create the controller per session.
  - `supported` = not iOS/Android.
  - `onTerminalOutput` feeds a chunked UTF-8 decoder (`const Utf8Decoder(allowMalformed: true).startChunkedConversion(...)`) whose output goes to `terminal.write`.
  - `writeToSession` → `session.write`.
- **Output:** `openedSession.output` → `ackRead()` → `controller.handleSessionOutput`.
- **Keyboard:** `terminal.onOutput` encodes to UTF-8. If `controller.handleKeyboardInput(bytes)` returns true the bytes are dropped; otherwise they go to `session.write`.
- **Teardown:** in `_closeSession` and `didUnmounted`, call `controller.dispose()`.
- **Panel:** `TerminalTabView` adds a `ValueListenableBuilder` on `progress`, placing the panel aligned to the bottom of the existing `Stack`.
- **Results:** a subscription to `results` shows snackbars via `ScaffoldMessenger.maybeOf(context)`. `Show in Finder` calls `fileAccess.reveal(path or folder)`.

- [ ] **Step 1: Write the failing widget tests.** Use a fake `ExecutionSession` whose output is driven by a fake peer `ZModemCore`, and a fake `ZmodemFileAccess` over a temp dir. Mount `TerminalTabView` inside `MaterialApp` + `Scaffold` with l10n delegates.
  - `utf8 split across chunks renders intact`: `'中文'` bytes split mid-character → the terminal buffer line contains `中文`.
  - `sz shows the panel then a Saved to snackbar`: during data the panel shows `a.bin`; after the session finishes the panel is gone and `Saved to <tmp>/a.bin` is shown.
  - `Cancel button aborts and shows Transfer cancelled`: the session receives the cancel sequence.
  - `typing during a transfer is not sent; Ctrl+C cancels`.
  - `closing the tab mid-transfer deletes the partial file`.
- [ ] **Step 2: Run and confirm failure.**
  - Run: `cd app_widget/terminal_plugin && flutter test test/zmodem/terminal_plugin_zmodem_test.dart`
  - Expected: compile error.
- [ ] **Step 3: Implement** the wiring, panel and snackbars.
- [ ] **Step 4: Run** the package tests and app tests.
  - Run: `cd app_widget/terminal_plugin && flutter test && cd ../.. && flutter test test/screens/terminal/`
  - Expected: all pass.
- [ ] **Step 5: Commit** (if authorised): `feat(terminal): sz/rz transfers with progress`

---

### Task 6: Real-PTY integration test on macOS

**Files:**
- Create: `integration_test/zmodem_transfer_test.dart`

**Interfaces:**
- Consumes `TerminalPlugin` / `TerminalTabView` with a real `LocalHostSpec`, and a fake `ZmodemFileAccess` (temp download dir, scripted upload picks).

**Tests** (skip when `/usr/bin/env which sz` fails):
- `sz in a local tab downloads byte-identically`:
  1. Make a temp dir containing a 2 MB random file.
  2. Type `cd <dir> && sz --binary f.bin\r` into the terminal.
  3. Wait until `ZmodemDownloadCompleted` arrives.
  4. Expect the file to be identical. Then type `echo DONE$((1))\r` and expect `DONE1` in the buffer, which shows the terminal is usable.
- `rz in a local tab uploads the picked file`: the fake picker returns a temp file. Expect `<cwd>/up.bin` to be identical.
- `cancel during a large sz leaves no partial file and a usable shell`: a 50 MB file, cancel once progress > 0. No file is left in the download dir, and `echo` works afterwards.

- [ ] **Step 1: Write the tests.**
- [ ] **Step 2: Run them.**
  - Run: `flutter test integration_test/zmodem_transfer_test.dart -d macos`
  - Expected: all pass. They should pass without new code if Tasks 1–5 are correct. Any failure is a defect to fix under systematic debugging, with a regression test added to the owning task's test file.
- [ ] **Step 3: Run the full verification.**
  - Run: `melos run analyze && melos run test && flutter build macos --debug`
  - Expected: clean, all pass, build succeeds.
- [ ] **Step 4: Commit** (if authorised): `test(terminal): sz/rz integration on macOS`
