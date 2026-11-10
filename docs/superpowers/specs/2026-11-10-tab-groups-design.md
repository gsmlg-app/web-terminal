# Tab Groups — Design

Date: 2026-11-10
Status: approved in conversation, pending implementation plan

## Why

The app is meant to replace iTerm on macOS. The user routinely works on
several projects at once with several tabs per project, so 20 tabs is
normal. All tabs currently appear as one flat grid in the tab switcher
(Cmd+Shift+P), which makes it hard to see which tab belongs to which
project. Groups exist purely to make that legible. They are not a project
manager.

## Goals

- Let the user put tabs into named groups by hand.
- Show the tab switcher sectioned by group, so 20 tabs read as a few
  labelled blocks.
- Add a shortcut that opens the switcher limited to the current tab's group.
- Remember groups across restarts, together with the existing tab restore.

## Non-goals

- No always-visible tab bar or sidebar. The user explicitly prefers the
  pop-up switcher.
- No automatic grouping of any kind, and no setting for it. The user
  rejected grouping by git root, by working directory, and auto-assignment
  on first `cd`.
- No colours or icons per group.
- Cmd+1–9 and Cmd+Shift+[ / ] are unchanged. They still walk the global
  tab order across all groups.

## Anti-goals (the feature fails if any of these happen)

- A tab changes group without the user doing it. For example, `cd` into
  another project must never move it.
- A newly opened tab lands in some group by itself.
- Existing behaviour regresses: switching, renaming, reordering,
  multi-select close, close confirmation, or tab restore.

## Behaviour (decided with the user)

### Membership

- Every new tab starts **ungrouped**, however it was opened (Cmd+T, the
  menu, a profile, SSH, SFTP, or restore of a tab that had no group).
- A tab belongs to at most one group.
- A tab's group changes only through an explicit user action.

### Group operations

- **Create:** "New group…" on a tab. It asks for a name, creates the group
  and moves that tab into it. Groups are never created empty.
- **Move a tab:** "Move to group ▸ <name>" moves it into an existing group.
- **Ungroup a tab:** "Remove from group".
- **Rename a group:** user-supplied name. Blank names are rejected and
  surrounding whitespace is trimmed, matching tab rename.
- **Close a group:** closes every tab in it. If any of those tabs is busy
  (`isTabBusy` in `lib/screens/terminal/close_confirmation.dart`, the
  existing foreground-process check), ask once first, listing the busy tabs.
  Idle groups close without asking.
- **Empty groups:** a group whose last tab closes or leaves is deleted
  automatically. *(builder call, see below)*

### Tab switcher (`lib/screens/terminal/widgets/tab_switcher.dart`)

- Cmd+Shift+P (Ctrl+Shift+P elsewhere) opens the switcher showing all tabs,
  in sections:
  - one section per group;
  - "Ungrouped" last, shown only when it has tabs;
  - the section containing the current tab first;
  - other groups in their stored order.
- **Section header:** `<group name> · <tab count>`. Clicking it collapses or
  expands the section, and collapse state is remembered. "Ungrouped" can be
  collapsed too. The current tab's section is always shown expanded when the
  switcher opens; that forced expansion is not saved, so the stored collapse
  state is unchanged. *(Claude's call, from builder check)*
- The "Ungrouped" header has no group menu.
- **Group-only mode:** Cmd+Shift+O (Ctrl+Shift+O elsewhere) opens the
  switcher showing only the current tab's section. If the current tab is
  ungrouped, it shows only the ungrouped tabs. The header title says which
  group is shown.
- **Keyboard navigation** (hjkl / arrows, Enter, Esc, Cmd+Backspace) works
  as today. Moving past the end of one section continues into the next
  visible section, and collapsed sections are skipped.
- **Tab card actions:** right-click (or long-press on touch) shows a menu:
  Rename…, Move to group ▸ (existing groups), New group…, Remove from group.
  Long-press currently goes straight to rename, so this replaces that with
  a menu that still offers Rename. *(builder call)*
- **Group header actions:** right-click (or long-press) shows Rename group…
  and Close group.
- **Reorder mode:** dragging a card onto another card moves the dragged tab
  next to the target:
  - it joins the target's group, or becomes ungrouped if the target is
    ungrouped;
  - in the global tab order it goes immediately before the target, and no
    other tab moves.

  The switcher must not write its on-screen order back as the global order.
  The current `TerminalTabReorderSessions` full-list approach would do that,
  and because the current group is displayed first, it would push that group
  to the front of the global order. Use a single-tab move event instead.
  *(Claude's call, from builder check)*
- **Staying open:** the switcher stays open after group actions so many tabs
  can be organised in one visit. That covers move, new group, remove from
  group, rename group, collapse/expand and close group. Changes show live,
  either by rebuilding from the tab bloc or by keeping the switcher's working
  copy in sync. Selecting a tab still closes the switcher, as today.
  *(Claude's call, from builder check)*
- **Select mode:** multi-select close works as today across sections.

### Window title

- In the app bar title, an active grouped tab shows `<group name> · <tab name>`.
- An ungrouped tab shows the tab name only, as today.

### Persistence

- Group membership, group names, group order and collapse state are saved
  with the existing open-tabs restore. That is the `terminal.open_tabs.v1`
  payload written by `_saveOpenTabsToDisk` and read by
  `_restoreOpenTabsFromDisk` in `lib/screens/terminal/terminal_screen.dart`.
- They follow the same `restoreTerminalTabs` setting. When restore is off,
  groups are not kept either.
- **Format:** the payload gains a `groups` list
  (`{id, name, collapsed}` in display order), and each tab descriptor gains
  an optional `groupId`.
- **Compatibility:**
  - Old payloads without these fields restore as all-ungrouped.
  - A `groupId` that is not in `groups` restores as ungrouped.
- The payload also gains `ungroupedCollapsed` (bool, default false).
- Group ids must be stable strings generated at creation. Tab ids today are
  `hashCode` strings that change every launch, so membership cannot be keyed
  on them across restarts.

### Localisation

- All new user-facing strings go through `app_lib/locale` ARB files (en,
  zh, zh_Hans, zh_Hant, de), regenerated with `melos run gen-l10n`.
- Existing hard-coded English strings in the switcher are out of scope.

## Constraints

- Follow the repo's BLoC conventions. Group state is UI/session state for
  the tab collection, so it belongs in `app_bloc/terminal_tab`
  (`TerminalTabBloc` / `TerminalTabLoaded`), with events for create, move,
  ungroup, rename, close and toggle collapse.
- The switcher stays a widget that receives data and reports results, as
  today. `TabSwitcherResult` gains variants for group operations, or uses
  callbacks the way `onRename` does.
- Closing a group reuses the existing per-tab close path, so cleanup and
  saving behave exactly like closing tabs one by one.
- Smallest correct change. Do not restyle the switcher beyond adding
  sections and menus.
- Tabs can close without going through the tab bloc:
  - the flex_tabs close button calls `tab.dispose()` in
    `third_party/flex_tabs/lib/src/ui/tab_group.dart`;
  - the host edit page calls `TabScope.of(context)!.dispose()`.

  So clearing a closed tab's membership and deleting groups that become
  empty must follow the actual tab list (`Tabs` children), not only the
  bloc's close event.
- Tests:
  - bloc tests for every group event, including membership after close,
    empty-group deletion and reorder interaction;
  - widget tests for the sectioned switcher, group-only mode, the context
    menu actions and drag-into-group;
  - round-trip tests for persistence, including old-format payloads.

## Calls made by Claude (not explicitly decided by the user)

- **Shortcut:** Cmd+Shift+O for group-only mode. The user accepted the
  shortcut idea but not this specific key.
- **Empty groups** are deleted automatically.
- **Drag behaviour:** dragging places the tab before the target card, while
  "Move to group" from the menu puts it at the end of the group. These are
  two separate gestures, so the rules don't conflict.
- **Group ordering:**
  - Groups are shown in creation order, except that the current tab's group
    goes first.
  - Moving a tab into a group puts it at the end of that group.
  - Within a section, tabs keep their relative global order.
- **Global order:** when a tab moves into a group, it also moves in the
  global tab order to just after that group's last tab. Cmd+1–9 / [ ] then
  stay roughly aligned with what the switcher shows. If the group has no
  other tabs, the tab's position is unchanged.
- **Long-press** opens a menu that includes Rename, instead of going
  straight to rename.
- **No group colours** in this version.
- **Ungrouped label:** "Ungrouped" / "未分组".

## Left to the builder

- Exact widget structure for sections (for example a `CustomScrollView` with
  per-section `SliverGrid`, or a flat list of header and card items) and how
  grid navigation maps across sections.
- Group id generation scheme.
- Exact menu widget (`showMenu` / `MenuAnchor`), as long as it works with
  mouse right-click on macOS and long-press on touch.
