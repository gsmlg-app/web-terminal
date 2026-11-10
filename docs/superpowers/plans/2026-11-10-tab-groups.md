# Tab Groups Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users put terminal tabs into named, manually managed groups. The pop-up tab switcher shows tabs sectioned by group, with a mode that shows only the current group. Groups survive restart through the existing tab restore.

**Architecture:**
- Group state is an immutable value, `TabGrouping`, held in `TerminalTabLoaded` and changed only by explicit `TerminalTabBloc` events.
- The bloc listens to the flex_tabs `Tabs` ChangeNotifier, so tabs closed outside the bloc are pruned from their groups.
- The switcher receives a live `ValueListenable<TabSwitcherData>` built from bloc state, and reports user actions through callbacks. It can therefore stay open while groups change.
- A pure function, `buildSwitcherSections`, decides section order and filtering, so that logic is unit-testable apart from the widget.
- Persistence extends the existing `terminal.open_tabs.v1` payload in `terminal_screen.dart`.

**Tech Stack:** Flutter 3.47, flutter_bloc / bloc_test, flex_tabs (third_party), Melos workspace, gen_l10n ARB files.

**Spec:** `docs/superpowers/specs/2026-11-10-tab-groups-design.md`

## Global Constraints

- New tabs always start ungrouped. The only exception is restore, which reapplies saved membership. Nothing ever changes a tab's group except an explicit user action.
- No automatic grouping and no setting for it. No tab bar or sidebar. No group colours.
- Cmd+1–9 and Cmd+Shift+[ / ] keep walking the global tab order (`Tabs.children`).
- Shortcuts:
  - Cmd+Shift+P (Ctrl+Shift+P off Apple) opens the switcher with all tabs.
  - Cmd+Shift+O (Ctrl+Shift+O off Apple) opens it showing only the current group.
- Section header text is `<group name> · <count>`. The ungrouped section is labelled with l10n `tabGroupUngrouped` ("Ungrouped" / "未分组") and has no group menu.
- Group names and tab names: trim, and reject empty.
- Group lifecycle:
  - A group is never created empty.
  - A group is deleted automatically when its last tab closes or leaves.
  - Closing a group asks once if any tab in it is busy (`isTabBusy`) and closes idle groups without asking.
- Window title:
  - grouped tab: `<group name> · <tab name>`;
  - ungrouped tab: unchanged.
- Persistence:
  - Fields: `groups: [{id, name, collapsed}]` in creation order, `ungroupedCollapsed: bool`, and an optional per-tab `groupId`.
  - Write `groups` only when non-empty, `ungroupedCollapsed` only when true, and `groupId` only when set. Old exact-payload tests stay valid.
  - Unknown or missing `groupId` restores as ungrouped. Groups follow `restoreTerminalTabs`.
- All new user-facing strings go in the `app_lib/locale` ARB files (en, zh, zh_Hans, zh_Hant, de), regenerated with `melos run gen-l10n`. Existing hard-coded English in the switcher stays as is.
- Use `<pkg>: any` for workspace dependencies.
- Format only the files you touch, with `dart format <file>`.
- Do not commit unless the user authorises it. The commit steps below are for when it is authorised.
  - Commit on `main`.
  - No "Generated with Claude Code" line and no Co-Authored-By trailer.

## Review Focus

1. **Switcher open while tabs change:** a tab closes in the background (process exits, or another close path) while the switcher is open. The switcher drops that card and its now-empty section without crashing. Covered in Task 4's "live data" test.
2. **Restore with a stale `groupId`:** a saved payload references a group id missing from `groups`, or `groups` has a non-list or garbage value. Restore still opens every tab, ungrouped, and does not wipe the saved tabs. Covered in Task 6.
3. **Group-only mode with an ungrouped current tab:** it shows just the ungrouped tabs, under the title "Ungrouped". Covered in Task 3.
4. **Keyboard navigation over collapsed sections:** arrows and hjkl skip the cards of collapsed sections, and Enter still selects the focused card. Covered in Task 4.
5. **Drag onto a card of the current group:**
   - the global order changes only for the dragged tab;
   - Cmd+1 still targets the same first tab unless that tab was dragged.

   Covered in Task 2 (`moveTabBefore`) and in Task 4's drag test, which asserts the single-move callback, not a full order.

---

## File Structure

| File | Responsibility |
|---|---|
| `app_bloc/terminal_tab/lib/src/tab_grouping.dart` (new, `part of 'bloc.dart'`) | Immutable `TabGroup` and `TabGrouping`: pure membership operations. |
| `app_bloc/terminal_tab/lib/src/{bloc,event,state}.dart` | Group events, the `grouping` state field, the Tabs-listener prune, and single-tab move. |
| `lib/screens/terminal/widgets/tab_switcher_sections.dart` (new) | `TabSwitcherData`, `TabSwitcherSection`, `buildSwitcherSections()`. Pure logic, no widgets. |
| `lib/screens/terminal/widgets/tab_switcher.dart` | Sectioned UI, group-only mode, context menus, cross-section drag, live data. |
| `lib/screens/terminal/widgets/terminal_app_bar.dart` | `SessionInfo.groupId`. |
| `lib/screens/terminal/terminal_screen.dart` | Wiring: Cmd+Shift+O, callbacks to bloc events, close-group confirmation, title prefix, persistence. |
| `lib/screens/terminal/close_confirmation.dart` | `confirmCloseGroup`. |
| `app_lib/locale/lib/arb/app_*.arb` + `gen_l10n/` | New strings. |

---

### Task 1: `TabGrouping` value model

**Files:**
- Create: `app_bloc/terminal_tab/lib/src/tab_grouping.dart`. Add it as `part 'tab_grouping.dart';` in `bloc.dart`, which already imports flex_tabs, equatable and widgets.
- Test: `app_bloc/terminal_tab/test/tab_grouping_test.dart`

**Interfaces:**
- Produces, used by Tasks 2, 3 and 6:
  ```dart
  @immutable
  final class TabGroup extends Equatable {
    const TabGroup({required this.id, required this.name, this.collapsed = false});
    final String id; final String name; final bool collapsed;
    TabGroup copyWith({String? name, bool? collapsed});
  }

  @immutable
  final class TabGrouping extends Equatable {
    const TabGrouping({this.groups = const [], this.membership = const {}, this.ungroupedCollapsed = false});
    final List<TabGroup> groups;               // creation order
    final Map<TabItem, String> membership;     // tab -> group id
    final bool ungroupedCollapsed;
    String? groupIdOf(TabItem tab);
    TabGroup? groupById(String id);
    TabGroup? groupOf(TabItem tab);
    TabGrouping createGroup({required String id, required String name, required TabItem tab});
    TabGrouping assign(TabItem tab, String? groupId);   // null = ungroup; unknown id = no-op
    TabGrouping renameGroup(String id, String name);
    TabGrouping toggleCollapsed(String? groupId);       // null = ungrouped section
    TabGrouping retainTabs(Iterable<TabItem> liveTabs); // drop dead members, then empty groups
  }
  ```
- Every operation returns a new instance. `retainTabs` and `assign` both delete any group left with no members.
- `props` covers `groups`, `membership` and `ungroupedCollapsed`.

- [ ] **Step 1: Write the failing tests** in `tab_grouping_test.dart`, using plain `TabItem()` instances `a`, `b`, `c`:
  - `createGroup adds the group and assigns the tab`: `g.groups.single == TabGroup(id: 'g1', name: 'web')` and `g.groupIdOf(a) == 'g1'`.
  - `createGroup trims the name and rejects blank`: name `'  web  '` gives `'web'`. Name `'   '` returns the same instance (`same(original)`).
  - `assign moves a tab and deletes the emptied group`: `a` is in g1 and `b` in g2. After `assign(a, 'g2')`, `g.groups.map((x) => x.id)` is `['g2']`.
  - `assign null ungroups and deletes the emptied group`: `groupIdOf(a)` is null and `groups` is empty.
  - `assign to unknown id is a no-op`: `same(original)`.
  - `renameGroup trims and ignores blank`.
  - `toggleCollapsed flips one group, and null flips ungroupedCollapsed`.
  - `retainTabs drops closed tabs and empty groups`: g1 = {a}, g2 = {b, c}. After `retainTabs([c])`, groups are `['g2']`, `groupIdOf(a)` is null, `groupIdOf(c)` is `'g2'`.
  - `operations never reorder remaining groups`: create g1, g2, g3, then empty g2. The order is `['g1', 'g3']`.

- [ ] **Step 2: Run them and confirm they fail.**
  - Run: `cd app_bloc/terminal_tab && flutter test test/tab_grouping_test.dart`
  - Expected: compile failure, because `TabGrouping` is undefined.

- [ ] **Step 3: Implement `tab_grouping.dart`** following the interface above.
  - Keep `membership` an unmodifiable `Map.of(...)` copy.
  - Delete empty groups with a single private `_dropEmptyGroups()` helper, shared by `assign` and `retainTabs`.

- [ ] **Step 4: Run the tests and confirm they pass.**
  - Run: `cd app_bloc/terminal_tab && flutter test test/tab_grouping_test.dart`
  - Expected: all pass.

- [ ] **Step 5: Commit** (if authorised): `feat(terminal_tab): add tab grouping model`

---

### Task 2: Bloc group events, prune on tab removal, single-tab move

**Files:**
- Modify: `app_bloc/terminal_tab/lib/src/state.dart`
  - `TerminalTabLoaded` gains `final TabGrouping grouping` (default `const TabGrouping()`).
  - Add it to `props` and `copyWith({TabGrouping? grouping})`.
- Modify: `app_bloc/terminal_tab/lib/src/event.dart`: the new events listed below.
- Modify: `app_bloc/terminal_tab/lib/src/bloc.dart`: handlers, the listener and the id generator.
- Test: `app_bloc/terminal_tab/test/terminal_tab_bloc_test.dart` (add a `group('groups', ...)`).

**Interfaces:**
- Consumes `TabGrouping` / `TabGroup` from Task 1.
- Produces, used by Tasks 4–6. All `sessionId` values are the existing `tab.hashCode.toString()` ids.
  ```dart
  TerminalTabBloc({String Function()? groupIdGenerator});
  // default generator: 'g${DateTime.now().microsecondsSinceEpoch}-${counter++}'

  class TerminalTabCreateGroup extends TerminalTabEvent { TerminalTabCreateGroup(this.sessionId, this.name); final String sessionId; final String name; }
  class TerminalTabMoveToGroup extends TerminalTabEvent { TerminalTabMoveToGroup(this.sessionId, this.groupId); final String sessionId; final String groupId; }
  class TerminalTabUngroup extends TerminalTabEvent { TerminalTabUngroup(this.sessionId); final String sessionId; }
  class TerminalTabRenameGroup extends TerminalTabEvent { TerminalTabRenameGroup(this.groupId, this.name); final String groupId; final String name; }
  class TerminalTabToggleGroupCollapsed extends TerminalTabEvent { TerminalTabToggleGroupCollapsed(this.groupId); final String? groupId; }
  class TerminalTabMoveTabBefore extends TerminalTabEvent { TerminalTabMoveTabBefore(this.sessionId, this.targetSessionId); final String sessionId; final String targetSessionId; }
  class TerminalTabRestoreGroups extends TerminalTabEvent { TerminalTabRestoreGroups(this.groups, {this.ungroupedCollapsed = false}); final List<TabGroup> groups; final bool ungroupedCollapsed; }
  // TerminalTabOpenTab gains: final String? groupId;  (named, default null; restore only)
  ```
- **Order rules:**
  - `CreateGroup` does not move the tab in the global order.
  - `MoveToGroup` moves the tab in `Tabs` to just after the group's last *other* member. If the group has no other member, the tab stays where it is.
  - `MoveTabBefore` assigns the tab to the target's group (or ungroups it if the target is ungrouped). It then calls `tabs.move(tab, indexOf(target))`, adjusted for removal when the tab sits before the target. No other tab moves.
  - `OpenTab` with a `groupId` that exists assigns that group. An unknown id leaves the tab ungrouped.
  - `RestoreGroups` replaces `grouping.groups` and `ungroupedCollapsed` and keeps current membership. It is sent before the restored tabs open, so `OpenTab(groupId:)` can resolve their groups.
- **Prune:**
  - On `TerminalTabStart` creating `Tabs`, call `tabs.addListener(_onTabsChanged)`.
  - `_onTabsChanged` adds a private `_TerminalTabTabsChanged` event.
  - Its handler emits `grouping: grouping.retainTabs(tabs.children)` only when that result differs.
  - Remove the listener in `close()`.
- Every group handler emits `copyWith(..., incrementVersion: true)` only on change.

- [ ] **Step 1: Write the failing bloc tests.** Use `bloc_test` with `TestTabItem` (already in the file) and `groupIdGenerator: () => 'g${n++}'`.
  - `CreateGroup assigns the tab and emits`: `grouping.groupOf(tab1)!.name == 'web'`.
  - `new tabs are ungrouped even when the active tab is grouped`: group `tab1`, open `tab2`. Expect `groupIdOf(tab2)` to be null.
  - `MoveToGroup places the tab after the group's last member`: tabs `[t1, t2, t3, t4]` with t1 and t2 in g0. After moving t4 into g0, `allTabs` is `[t1, t2, t4, t3]`.
  - `MoveToGroup into a group with no other member keeps the position`.
  - `MoveTabBefore moves only the dragged tab and adopts the target group`: `[t1, t2, t3]` with t3 in g0. After `MoveTabBefore(t1, t3)`, the order is `[t2, t1, t3]` and `groupIdOf(t1) == 'g0'`.
  - `MoveTabBefore onto an ungrouped target ungroups`.
  - `closing a tab via TerminalTabCloseSession drops it and deletes the empty group`.
  - `closing a tab outside the bloc (tab.dispose()) is pruned`: dispose directly, `await Future<void>.delayed(Duration.zero)`, then expect `grouping.groups` to be empty.
  - `RestoreGroups then OpenTab(groupId:) restores membership; an unknown groupId stays ungrouped`.
  - `RenameGroup and ToggleGroupCollapsed(null) update grouping`.
  - `NextTab/GoToTab still follow global order with groups present`: g0 = {t3}. `GoToTab(0)` activates t1.

- [ ] **Step 2: Run them and confirm they fail.**
  - Run: `cd app_bloc/terminal_tab && flutter test`
  - Expected: compile errors for the undefined events.

- [ ] **Step 3: Implement** the state field, events, handlers, listener and generator described above. Reuse the existing `_findTabById`.

- [ ] **Step 4: Run the package tests and analyzer.**
  - Run: `cd app_bloc/terminal_tab && flutter test && flutter analyze`
  - Expected: all pass, no issues.

- [ ] **Step 5: Commit** (if authorised): `feat(terminal_tab): add tab group events`

---

### Task 3: Switcher section model and l10n strings

**Files:**
- Create: `lib/screens/terminal/widgets/tab_switcher_sections.dart`
- Modify: `lib/screens/terminal/widgets/terminal_app_bar.dart`: `SessionInfo` gains `final String? groupId;` (named, default null).
- Modify: `app_lib/locale/lib/arb/app_en.arb`, `app_zh.arb`, `app_zh_Hans.arb`, `app_zh_Hant.arb`, `app_de.arb`, then run `melos run gen-l10n`.
- Test: `test/screens/terminal/widgets/tab_switcher_sections_test.dart`

**Interfaces:**
- Produces, used by Tasks 4 and 5:
  ```dart
  @immutable
  class TabSwitcherGroup { const TabSwitcherGroup({required this.id, required this.name, required this.collapsed}); final String id; final String name; final bool collapsed; }

  @immutable
  class TabSwitcherData {
    const TabSwitcherData({required this.sessions, required this.currentSessionId, this.groups = const [], this.ungroupedCollapsed = false});
    final List<SessionInfo> sessions;     // global order; SessionInfo.groupId set
    final String? currentSessionId;
    final List<TabSwitcherGroup> groups;  // creation order
    final bool ungroupedCollapsed;
  }

  @immutable
  class TabSwitcherSection {
    const TabSwitcherSection({required this.groupId, required this.name, required this.sessions, required this.collapsed});
    final String? groupId;               // null = ungrouped
    final String name;                   // group name, or the ungroupedLabel passed in
    final List<SessionInfo> sessions;    // relative global order
    final bool collapsed;                // effective: forced false for the current tab's section
  }

  List<TabSwitcherSection> buildSwitcherSections(
    TabSwitcherData data, {
    required String ungroupedLabel,
    bool currentGroupOnly = false,
  });
  ```
- **Ordering:**
  - The current tab's section comes first.
  - Remaining groups follow in `groups` order.
  - The ungrouped section comes last.
  - Empty sections are omitted.
  - A session whose `groupId` is not in `groups` counts as ungrouped.
  - `currentGroupOnly` returns just the current tab's section. If no session is current, it returns all sections.
- **ARB keys** (en / zh_Hans; zh and zh_Hant mirror Chinese; de uses German):
  - `tabGroupUngrouped`: "Ungrouped" / "未分组"
  - `tabGroupMoveTo`: "Move to group" / "移到分组"
  - `tabGroupNew`: "New group…" / "新建分组…"
  - `tabGroupRemove`: "Remove from group" / "移出分组"
  - `tabGroupRename`: "Rename group…" / "重命名分组…"
  - `tabGroupClose`: "Close group" / "关闭分组"
  - `tabGroupNameHint`: "Group name" / "分组名称"
  - `tabRename`: "Rename…" / "重命名…"
  - `tabGroupCloseConfirmTitle`: "Close Group?" / "关闭分组？"
  - `tabGroupCloseConfirmMessage`, with the same `{count}`/`{titles}` plural shape as `quitConfirmMessage`: "{count, plural, =1{1 tab in this group has a running program:} other{{count} tabs in this group have running programs:}}\n{titles}\n\nClosing the group will terminate them."
  - `close`: reuse it if it already exists, otherwise add it.
  - Each key gets an `@key` description, following the existing style.

- [ ] **Step 1: Write the failing tests** in `tab_switcher_sections_test.dart`. Sessions s1–s5: g1 = {s2, s4}, g2 = {s5}, s1 and s3 ungrouped. `groups` = [g1 'api', g2 'web'].
  - `current tab's group comes first`: current s5 gives section names `['web', 'api', 'Ungrouped']`.
  - `sessions keep relative global order within a section`: the g1 section has `['s2', 's4']`.
  - `ungrouped section is last and omitted when empty`.
  - `unknown groupId counts as ungrouped`.
  - `currentGroupOnly returns only the current section`: current s3 gives `['Ungrouped']` with `['s1', 's3']`.
  - `current section is never collapsed`: g1 is collapsed and current is s2. The g1 section's `collapsed` is false while `data.groups` still says true.

- [ ] **Step 2: Run them and confirm they fail.**
  - Run: `flutter test test/screens/terminal/widgets/tab_switcher_sections_test.dart`
  - Expected: compile failure.

- [ ] **Step 3: Implement** `tab_switcher_sections.dart`, `SessionInfo.groupId` and the ARB entries. Then run `melos run gen-l10n`.

- [ ] **Step 4: Run the tests and l10n analyze.**
  - Run: `flutter test test/screens/terminal/widgets/tab_switcher_sections_test.dart && melos exec --scope app_locale -- flutter analyze`
  - Expected: pass.

- [ ] **Step 5: Commit** (if authorised): `feat(terminal): add tab switcher section model and group strings`

---

### Task 4: Sectioned tab switcher widget

**Files:**
- Modify: `lib/screens/terminal/widgets/tab_switcher.dart`
- Test: `test/screens/terminal/widgets/tab_switcher_test.dart` (update and extend)

**Interfaces:**
- Consumes `TabSwitcherData`, `buildSwitcherSections` and `SessionInfo.groupId` from Task 3.
- Produces, used by Task 5. These replace the `sessions` / `currentSessionId` / `onReorder` parameters:
  ```dart
  class TabSwitcherCallbacks {
    const TabSwitcherCallbacks({this.onRename, this.onMoveBefore, this.onCreateGroup, this.onMoveToGroup, this.onUngroup, this.onRenameGroup, this.onToggleCollapsed, this.onCloseGroup});
    final void Function(String sessionId, String title)? onRename;
    final void Function(String sessionId, String targetSessionId)? onMoveBefore;
    final void Function(String sessionId, String name)? onCreateGroup;
    final void Function(String sessionId, String groupId)? onMoveToGroup;
    final ValueChanged<String>? onUngroup;
    final void Function(String groupId, String name)? onRenameGroup;
    final ValueChanged<String?>? onToggleCollapsed;
    final ValueChanged<String>? onCloseGroup;
  }

  Future<TabSwitcherResult?> showTabSwitcher(
    BuildContext context, {
    required ValueListenable<TabSwitcherData> data,
    bool currentGroupOnly = false,
    TabSwitcherCallbacks callbacks = const TabSwitcherCallbacks(),
  });
  ```
- `TabSwitcherResult` variants are unchanged: Select, Close, CloseSelected.

**Behaviour to implement:**
- **Live data:** listen to `data` and rebuild sections on every change.
  - Keep focus on the same session id, or the nearest remaining card if it is gone.
  - Drop selected ids that no longer exist.
  - The switcher does not keep its own copy of the order.
- **Layout:** a `CustomScrollView`. Per section:
  - a header row (`ValueKey('tab-switcher-section-${groupId ?? 'ungrouped'}')`) showing `'$name · ${sessions.length}'`;
  - when not collapsed, a `SliverGrid` with the existing card builder, card keys unchanged (`tab-switcher-card-$id`).
  - Keep the existing `maxWidth: 560, maxHeight: 520` box and the column count rule, computed from the largest visible section.
- **Headers:**
  - Tapping a header calls `onToggleCollapsed(groupId)`.
  - Right-click or long-press on a group header (not "Ungrouped") opens a menu with `tabGroupRename` and `tabGroupClose`.
  - Rename uses the existing `_RenameTabDialog` pattern, titled with `tabGroupRename` and hinted with `tabGroupNameHint`.
- **Cards:** right-click (`onSecondaryTapUp`) or long-press opens a menu:
  - `tabRename` (the existing rename flow);
  - `tabGroupMoveTo` ▸ each group except the card's own, which calls `onMoveToGroup`;
  - `tabGroupNew` asks for a name and calls `onCreateGroup`;
  - `tabGroupRemove` is shown only when the card is grouped and calls `onUngroup`.

  Long-press no longer opens rename directly.
- **Group-only title:** in `currentGroupOnly` the header title is the section name instead of "Switch Tab".
- **Navigation:** hjkl and arrows navigate over the flattened list of visible cards, skipping collapsed sections.
  - Left/right move ±1.
  - Up/down move ±cols within a section and clamp into the previous or next section.
  - Enter, Esc and Cmd/Ctrl+Backspace keep today's behaviour.
- **Reorder mode:** dropping card A on card B calls `onMoveBefore(A.id, B.id)` immediately. The done and cancel buttons only leave the mode. The live data shows the result.
- **Close group:** `onCloseGroup(groupId)`. The switcher stays open, and the screen handles confirmation.

- [ ] **Step 1: Update and add the failing widget tests.** The `pumpTabSwitcher` helper takes a `ValueNotifier<TabSwitcherData>`, plus `currentGroupOnly` and `TabSwitcherCallbacks` parameters.
  - Replace `reorder button starts reorder and confirms new order` with `dragging a card onto another calls onMoveBefore once`: drag card 1 onto card 3, expect `moves == [('1', '3')]`.
  - Replace `long press opens rename input and updates title` with `long press opens a menu whose Rename updates title`. It taps `tabRename`, then keeps the existing rename assertions.
  - `shows sections with name and count, current group first`: g1 'api' = {2}, current '2'. Expect `api · 1` above `Ungrouped · 2`, checked with `tester.getTopLeft(...).dy`.
  - `header tap calls onToggleCollapsed and collapsed sections hide cards`. Rebuild the data with `collapsed: true` and expect `find.byKey(ValueKey('tab-switcher-card-3'))` to find nothing.
  - `context menu moves tab to an existing group / new group / out of group`. Assert each callback's arguments; for New group, enter the name `'web'` in the dialog.
  - `group header menu renames and closes group`.
  - `currentGroupOnly shows only the current section and its name as title`.
  - `live data removes a closed tab without error`: remove session 3 from the notifier, pump, and expect `tester.takeException()` to be null and card 3 gone.
  - `arrow keys skip collapsed sections`: three sections, the middle one collapsed. ArrowDown from the first section's last row focuses the third section's card, then Enter returns `TabSwitcherSelect` with that id.
  - Keep the existing tests (`confirms and returns selected tabs to close`, the overflow and display-feature tests), adapting only the helper.

- [ ] **Step 2: Run them and confirm they fail.**
  - Run: `flutter test test/screens/terminal/widgets/tab_switcher_test.dart`
  - Expected: compile failure on the new `showTabSwitcher` signature.

- [ ] **Step 3: Implement** the behaviour above in `tab_switcher.dart`. Build sections only through `buildSwitcherSections`. Take the ungrouped label from `context.l10n.tabGroupUngrouped`; the test app must add `AppLocalizations` delegates to `MaterialApp`, as the other l10n widget tests do.

- [ ] **Step 4: Run the tests.**
  - Run: `flutter test test/screens/terminal/widgets/`
  - Expected: all pass.

- [ ] **Step 5: Commit** (if authorised): `feat(terminal): sectioned tab switcher with group actions`

---

### Task 5: Screen wiring: shortcuts, group actions, close-group confirmation, title

**Files:**
- Modify: `lib/screens/terminal/terminal_screen.dart`:
  - `_showTabSwitcher` gains `{bool currentGroupOnly = false}`;
  - `_handleTerminalKeyEvent`;
  - `_buildSessionList` sets `groupId`;
  - `_getCurrentSessionName`.
- Modify: `lib/screens/terminal/close_confirmation.dart`: add `confirmCloseGroup`.
- Test: `test/screens/terminal/terminal_screen_test.dart`, `test/screens/terminal/close_confirmation_test.dart`

**Interfaces:**
- Consumes the Task 2 events and the Task 4 `showTabSwitcher` / `TabSwitcherCallbacks`.
- Produces:
  ```dart
  /// Returns true when every tab in [tabs] may close (asks once if any is busy).
  Future<bool> confirmCloseGroup(BuildContext context, List<TabItem> tabs);
  ```
  It uses `findBusyTabs` and the `tabGroupCloseConfirm*` strings, with Cancel / `close` buttons.
- **Switcher data:** `_showTabSwitcher` builds a `ValueNotifier<TabSwitcherData>` from the bloc state. It updates the notifier from `_terminalTabBloc.stream` while the route is open, then cancels the subscription and disposes the notifier after the route returns.
  - The busy set is computed once at open, as today.
  - Each callback maps 1:1 to a Task 2 event.
- **`onCloseGroup(groupId)`:**
  1. Collect the group's tabs.
  2. `await confirmCloseGroup`.
  3. Dispatch `TerminalTabCloseSession` for each tab.

  The switcher stays open, and the live data empties the section.
- **Shortcuts:** `keyO && shift && mod` → `_showTabSwitcher(currentGroupOnly: true)`, placed next to the existing `keyP` branch.
- **Title:** `_getCurrentSessionName` returns `'${group.name} · ${tab.displayTitle}'` when `state.grouping.groupOf(activeTab)` is non-null.

- [ ] **Step 1: Write the failing tests.**
  - `terminal_screen_test.dart`: `Cmd+Shift+O opens the switcher limited to the current group`. Seed two tabs, put the active one in group 'web' via `TerminalTabCreateGroup`, send meta+shift+O on macOS (`TargetPlatformVariant.only(TargetPlatform.macOS)`). Expect the `web · 1` header, and expect the other tab's card to be absent.
  - Same file: `app bar title shows group name prefix for grouped tab`.
  - Same file: `new tab opened with Cmd+T is ungrouped while active tab is grouped`.
  - `close_confirmation_test.dart`:
    - `confirmCloseGroup returns true without dialog when no tab is busy`;
    - `confirmCloseGroup lists busy tabs and returns false on Cancel`.

    Reuse the busy-tab fakes already in that file.

- [ ] **Step 2: Run them and confirm they fail.**
  - Run: `flutter test test/screens/terminal/terminal_screen_test.dart test/screens/terminal/close_confirmation_test.dart`
  - Expected: failures or compile errors on the new behaviour.

- [ ] **Step 3: Implement** the wiring above.

- [ ] **Step 4: Run the tests.**
  - Run: `flutter test test/screens/terminal/`
  - Expected: all pass.

- [ ] **Step 5: Commit** (if authorised): `feat(terminal): wire tab groups into terminal screen`

---

### Task 6: Persist and restore groups

**Files:**
- Modify: `lib/screens/terminal/terminal_screen.dart`:
  - `_saveOpenTabsToDisk` and `_encodeTab` add `groupId`;
  - the payload adds `groups` / `ungroupedCollapsed`;
  - `_restoreOpenTabsFromDisk`, `_restoreTab`, `_openLocalShellWithProfile`, `_restoreSshSession` pass through `groupId`.
- Test: `test/screens/terminal/terminal_tab_persistence_test.dart`

**Interfaces:**
- Consumes `TerminalTabRestoreGroups`, `TerminalTabOpenTab(groupId:)` and `TabGroup` from Task 2.
- **Save:** `groupId` goes on a tab descriptor only when the tab is grouped. `groups` is written as `[{'id', 'name', 'collapsed'}]` only when non-empty. `ungroupedCollapsed` is written only when true.
- **Restore:**
  1. Parse `groups` defensively. Skip any entry that is not a map or lacks string `id`/`name`; a missing `collapsed` defaults to false.
  2. Dispatch `TerminalTabRestoreGroups` before opening tabs.
  3. Pass `item['groupId'] as String?` (only if it is a String) through to `TerminalTabOpenTab(groupId:)`.
- Group changes must trigger a save. `_onStateChanged` already saves on every emitted state, so verify this in a test rather than adding code.

- [ ] **Step 1: Write the failing tests.**
  - `groups round-trip through save and restore`:
    1. Seed two local tabs and create group 'web' with tab 0.
    2. Toggle the ungrouped section collapsed, then save.
    3. Expect the payload to contain `'groups': [{'id': <id>, 'name': 'web', 'collapsed': false}]`, `'ungroupedCollapsed': true`, and `tabs[0]['groupId'] == <id>`.
    4. Restore in a new harness. Expect `grouping.groupOf(tabs[0])!.name == 'web'`, `groupIdOf(tabs[1]) == null` and `ungroupedCollapsed` true.
  - `old payload without groups restores all tabs ungrouped`.
  - `unknown groupId and malformed groups restore tabs ungrouped`: `groups: 'oops'`, and a tab with `groupId: 'missing'`. Both tabs restore, `grouping.groups` is empty, and the saved key is not removed.
  - The existing exact-payload test (`'$source local tabs save and restore…'`) stays unchanged and must still pass.

- [ ] **Step 2: Run them and confirm they fail.**
  - Run: `flutter test test/screens/terminal/terminal_tab_persistence_test.dart`
  - Expected: the new tests fail.

- [ ] **Step 3: Implement** save and restore as described above.

- [ ] **Step 4: Run the full verification.**
  - Run: `melos run analyze && melos run test && flutter build macos --debug`
  - Expected: analyze clean, all suites pass, build succeeds.

- [ ] **Step 5: Commit** (if authorised): `feat(terminal): persist tab groups with tab restore`
