# Product Requirements Document (PRD)

## Title
Mobile Shell Experience (Android + iOS)

## Summary
Provide a native-like shell experience on Android and iOS, including local root filesystem access on Android (Termux-style) and an iOS shell emulator (a-shell-style), plus a new shell screen UI that replaces flex-tabs with an AppBar-based design while keeping multi-session tabs.

## Goals
- Deliver a local shell with a root filesystem on Android and iOS.
- Provide remote access options: SSH shell and SFTP server sessions.
- Redesign the shell screen to use an AppBar with fullscreen and session creation actions.
- Maintain consistent UX and navigation across platforms.

## Non-Goals
- Implementing a full package manager or Linux distribution UI.
- Replacing the existing app navigation architecture outside the shell screen.
- Providing root or jailbreak capabilities.

## Target Users
- Developers or power users who need local terminal access on mobile.
- Users who manage remote servers via SSH or SFTP from mobile.

## User Stories
- As a user on Android, I can open a local shell backed by a root filesystem like Termux.
- As a user on iOS, I can open a local shell backed by a root filesystem like a-shell.
- As a user, I can open a new local shell or remote session from a plus menu in the AppBar.
- As a user, I can toggle fullscreen mode to hide the app shell navigation.

## Functional Requirements

### Local Shell
- Android: Provide a local shell environment with a root filesystem accessible from the shell (sandboxed under app files). Current rootfs is not working and must be fixed using a Termux-style approach.
- iOS: Provide a local shell emulator (Documents-based, ios_system-style). No PTY support is expected.
- The shell should start in a defined home directory.
- File access should be scoped to the app sandbox and local rootfs on Android; desktop OS should use their native filesystem without extra rootfs work.
- Add a settings module for local shell configuration within the existing terminal settings.
- Add a setting for maximum open shells; default limit is 10.
- Support multiple local shell profiles with configurable:
  - Shell (bash, zsh, etc.).
  - Environment variables.
  - Alias definitions.
  - Font family.
  - Font size.
  - Color theme.
  - Default profile selection for new sessions.

### Remote Sessions
- Support opening an SSH shell session. Settings UI exists but the connection flow is incomplete and must be finished.
- SSH should support password and key-based authentication using configured keys (unencrypted keys only for the first release).
- Support opening an SFTP session (planned, not implemented in this release).
- Provide a selection flow from the AppBar plus menu to choose session type.
- SFTP future flow should reuse the file manager UI against the selected SSH host.

### Shell Screen UI
- Replace the existing flex-tabs layout on the shell screen with an AppBar.
- Remove flex-tabs from the shell screen. Keep multi-session tabs behavior but not via flex-tabs.
- Use the AppBar title as the session selector. Tapping the title opens a popup menu listing active shells to switch between.
- AppBar left action: toggle fullscreen, hiding the app shell navigation.
- AppBar right action: plus dropdown menu with actions:
  - Open local shell
  - Open remote SSH shell
  - Open remote SFTP server
- The shell view does not use a context menu; selection and copy should still work.

## UX Requirements
- The AppBar should remain visible in non-fullscreen mode.
- Fullscreen mode should maximize terminal real estate and hide the app shell navigation.
- Session creation should be no more than two taps from the shell screen.
- Maintain consistency with existing theme and typography.

## Platform Requirements
- Android: integrate or bundle a rootfs suitable for a local shell experience (Termux-style rootfs).
- iOS: implement a shell emulator using ios_system (a-shell style); no PTY is required.
- Ensure compliance with platform sandboxing and distribution rules.
- iOS shell limitations (no true PTY) are acceptable; document expected behavior and planned feature expansion.

## Analytics and Telemetry (Optional)
- Track session creation type (local, SSH, SFTP).
- Track fullscreen toggle usage.

## Acceptance Criteria
- Android device can open a local shell with rootfs access.
- iOS device can open a local shell emulator session (ios_system-based).
- Shell screen uses AppBar instead of flex-tabs.
- Fullscreen action hides app shell navigation and restores it when toggled back.
- Plus menu opens a chooser for local shell, SSH, and SFTP sessions.
- SSH connections succeed with password auth and unencrypted key auth.
- Verified on Android and iOS emulators with local shell and session flows working.

## Dependencies
- Flutter UI for shell screen.
- Platform-specific shell/rootfs implementation for Android and iOS.
- iOS shell emulator development document and feature roadmap (new doc).

## Risks
- Platform policy restrictions around executing local shells.
- Rootfs size and performance constraints on mobile.
- Maintaining consistent behavior across platforms.

## Open Questions
- What rootfs distribution should be used for Android, and how should it be installed or updated (Termux-style)?
- How are SSH/SFTP connection profiles stored and secured?
- Is there an existing terminal emulator package in the repo to reuse?
- How is fullscreen state persisted across sessions or app restarts?
- What is the expected minimum OS version for Android and iOS?
- What is the expected iOS shell behavior for job control and interactive apps (given no PTY)?
- Should we add a dedicated developer document for iOS shell emulator development and feature roadmap?

## Milestones (Proposed)
1. Shell screen AppBar refactor and session menu UX.
2. Android local shell and rootfs integration.
3. iOS local shell and rootfs integration.
4. Complete remote SSH session flow.
5. Add remote SFTP session flow (future).
