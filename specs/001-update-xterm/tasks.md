---

description: "Task list template for feature implementation"
---

# Tasks: Update Xterm Terminal Widget

**Input**: Design documents from `/specs/001-update-xterm/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/, quickstart.md

**Tests**: The examples below include test tasks. Tests are OPTIONAL - only include them if explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on plan.md structure

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Review existing terminal architecture in `app_widget/xterm/lib/src`
- [x] T002 [P] Capture baseline behavior expectations in `specs/001-update-xterm/research.md`
- [x] T003 [P] Inventory current regression issues in `app_widget/xterm/test`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Define terminal behavior acceptance checklist in `specs/001-update-xterm/contracts/terminal-behavior.md`
- [x] T005 Establish performance verification notes in `specs/001-update-xterm/quickstart.md`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Reliable Terminal Core (Priority: P1) 🎯 MVP

**Goal**: Restore reliable rendering and input handling for core terminal usage

**Independent Test**: Open a terminal session, run commands with streaming output, and confirm
accurate rendering and input responsiveness.

### Implementation for User Story 1

- [x] T006 [P] [US1] Audit buffer rendering paths in `app_widget/xterm/lib/src/core/buffer`
- [x] T007 [P] [US1] Audit escape sequence handling in `app_widget/xterm/lib/src/core/escape`
- [x] T008 [US1] Fix rendering order and line wrapping issues in `app_widget/xterm/lib/src/core/buffer/buffer.dart`
- [x] T009 [US1] Fix cursor positioning issues in `app_widget/xterm/lib/src/core/cursor.dart`
- [x] T010 [US1] Validate output streaming handling in `app_widget/xterm/lib/src/core/state.dart`
- [x] T011 [US1] Update regression fixtures in `app_widget/xterm/test/src/terminal_test.dart`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Accurate Input & Selection (Priority: P2)

**Goal**: Ensure keyboard shortcuts, selection, and clipboard behavior match standard terminal expectations

**Independent Test**: Select and copy text, then verify clipboard contents match selected ranges.

### Implementation for User Story 2

- [x] T012 [P] [US2] Review keyboard input mappings in `app_widget/xterm/lib/src/ui/input_map.dart`
- [x] T013 [P] [US2] Review gesture selection handling in `app_widget/xterm/lib/src/ui/gesture`
- [x] T014 [US2] Fix selection range calculations in `app_widget/xterm/lib/src/ui/selection_mode.dart`
- [x] T015 [US2] Fix copy/paste behavior in `app_widget/xterm/lib/src/ui/custom_text_edit.dart`
- [x] T016 [US2] Update keyboard shortcut routing in `app_widget/xterm/lib/src/ui/shortcut/shortcuts.dart`
- [x] T017 [US2] Add selection regression coverage in `app_widget/xterm/test/terminal/terminal_search_test.dart`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Terminal Behavior Alignment (Priority: P3)

**Goal**: Document expected terminal behavior based on emulator design research

**Independent Test**: Review documentation and confirm behavior expectations are described clearly.

### Implementation for User Story 3

- [x] T018 [US3] Draft terminal behavior guide in `app_widget/xterm/README.md`
- [x] T019 [US3] Update design rationale references in `specs/001-update-xterm/research.md`
- [x] T020 [US3] Align contract language in `specs/001-update-xterm/contracts/terminal-behavior.md`

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T021 [P] Run targeted checks for `app_widget/xterm` (document command outputs in `specs/001-update-xterm/quickstart.md`)
- [x] T022 Capture final validation notes in `specs/001-update-xterm/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Can reuse US1 outcomes but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - Depends on completion of US1 fixes to document behavior

### Within Each User Story

- Audits/reviews before implementation changes
- Core terminal fixes before regression fixture updates
- Documentation after behavior is verified

### Parallel Opportunities

- Audit tasks within each story marked [P] can run in parallel
- Documentation updates can proceed once core fixes are complete

---

## Parallel Example: User Story 1

```bash
# Launch audit tasks together:
Task: "Audit buffer rendering paths in app_widget/xterm/lib/src/core/buffer"
Task: "Audit escape sequence handling in app_widget/xterm/lib/src/core/escape"
```

## Parallel Example: User Story 2

```bash
# Launch input review tasks together:
Task: "Review keyboard input mappings in app_widget/xterm/lib/src/ui/input_map.dart"
Task: "Review gesture selection handling in app_widget/xterm/lib/src/ui/gesture"
```

## Parallel Example: User Story 3

```bash
# Launch documentation updates together:
Task: "Draft terminal behavior guide in app_widget/xterm/README.md"
Task: "Align contract language in specs/001-update-xterm/contracts/terminal-behavior.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Run quickstart checklist for output rendering and input response
5. Share findings before continuing to additional stories

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Validate output rendering stability → Share results
3. Add User Story 2 → Validate selection/clipboard behaviors → Share results
4. Add User Story 3 → Publish behavior guide and contracts
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3 (after US1 fixes)
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing (if tests are added)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
