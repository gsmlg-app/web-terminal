# AGENTS.md

Guidance for automation and coding agents working in this repository.

## Project Overview
Flutter monorepo template with modular architecture, BLoC state management, and clean separation across workspace packages.

## Repository Structure
- `lib/` main app entry
- `app_bloc/` BLoC packages
- `app_lib/` core utilities (db, theme, locale, logging, provider)
- `app_widget/` reusable UI components
- `app_plugin/` federated plugins
- `bricks/` Mason templates
- `test/` app tests
- `third_party/` modified third-party packages

## Commands (Build/Lint/Test)
- Setup workspace: `melos bootstrap` and `mason get`
- Full prepare: `melos run prepare`
- Analyze (lint): `melos run analyze`
- Format: `melos run format`
- Fix imports/lints: `melos run fix`
- Build runner: `melos run build-runner`
- Validate deps: `melos run validate-dependencies`
- Generate l10n: `melos run gen-l10n`
- Brick tests: `melos run brick-test`
- Run all tests (workspace): `melos run test`
- Run all tests (app): `flutter test`
- Run single test file: `flutter test test/widget_test.dart`
- Run single test by name: `flutter test --name "My widget does X"`
- Run tests in package: `melos exec --scope <pkg> -- flutter test`
- Build app (example): `flutter build apk` or `flutter build ios`

## Formatting and Tooling
- Run `melos run format` before final review.
- Use `melos run fix` to organize imports and lints.
- Prefer `dart format` only for isolated files.
- Keep generated files in sync with build runner.
- Re-run lints after large refactors.

## Key Entry Points
- `lib/main.dart` app initialization
- `lib/app.dart` root widget and theme wiring
- `lib/router.dart` GoRouter configuration

## Cursor/Copilot Rules
- No `.cursor/rules/`, `.cursorrules`, or `.github/copilot-instructions.md` files found.
- If any are added later, mirror them here.

## Code Style (General)
- Follow `analysis_options.yaml` and `flutter_lints` defaults.
- Prefer `const` constructors and `const` widgets where possible.
- Use single quotes for strings.
- Avoid inline comments unless explicitly required.
- Keep files focused; split large widgets or blocs into parts.
- Keep line length within Flutter/Dart defaults (80-100 chars).
- Use trailing commas for widget/build method formatting.
- Avoid one-letter variable names except in short loops.

## Imports
- Import order: Dart SDK, package, local.
- Separate import groups with a single blank line.
- Prefer explicit imports over `show`/`hide` unless needed.
- Do not use relative imports across packages; use package imports.

## Types and Signatures
- Specify return and parameter types explicitly.
- Avoid `dynamic` unless required by platform APIs.
- Use `final` for variables that never change.
- Use `late` only when initialization order demands it.
- Prefer typed collection literals: `<String, int>{}`.

## Null Safety and Async
- Default to non-nullable types and `required` parameters.
- Avoid `!` unless the value is guarded or asserted.
- Prefer `async`/`await` over raw `then` chains.
- Cancel timers/streams in `dispose` or bloc close.

## Naming Conventions
- Classes, enums, typedefs: `UpperCamelCase`.
- Methods, variables, fields: `lowerCamelCase`.
- Constants: `lowerCamelCase` (use `const`), not SCREAMING.
- File names: `snake_case.dart`.
- Widget files match widget name, e.g. `profile_card.dart`.

## Widget Guidelines
- Keep widgets stateless when possible.
- Prefer composition over inheritance.
- Avoid heavy logic in `build`; move to helpers/blocs.
- Use `Theme.of(context)` and `context.select`/`watch` appropriately.
- Keep `build` methods short; extract sub-widgets.

## BLoC Guidelines
- Use `flutter_bloc` patterns consistently.
- Events and states live with their bloc in `app_bloc/`.
- Prefer sealed-style patterns via `freezed` if already used.
- Emit states immutably; avoid mutable state in bloc.
- Keep side effects in bloc, not in widgets.

## Testing Guidelines
- Prefer `testWidgets` for UI and `test` for pure Dart.
- Use clear `group` and test names for behavior.
- Build widgets with required providers and blocs.
- Keep golden tests deterministic; avoid time-based flakiness.
- Run the narrowest test command first.

## Performance and UX
- Avoid unnecessary rebuilds; use `const` and selectors.
- Cache expensive computations outside `build` methods.
- Use `ListView.builder` for long lists.

## Error Handling and Logging
- Use `try/catch` around IO, network, and plugin calls.
- Log errors via `app_logging` utilities.
- Re-throw or wrap errors when higher layers must react.
- Prefer user-friendly error states in UI.

## Localization
- Source localized strings in `app_lib/locale`.
- Run `melos run gen-l10n` after adding strings.
- Avoid hard-coded user-facing strings in widgets.

## Documentation and Assets
- Update docs only when requested.
- Add new assets to the relevant `pubspec.yaml`.
- Keep assets organized by feature or package.

## Security and Secrets
- Never commit credentials, tokens, or `.env` files.
- Sanitize logs for PII or secrets when logging errors.

## Package Management
- Use Melos workspace packages.
- In `pubspec.yaml`, use `<package_name>: any` for workspace deps.
- Do not use path dependencies for workspace packages.
- Keep dependencies in package-level `pubspec.yaml`, not root.

## Mason Bricks
- See `docs/BRICKS.md` for brick usage and templates.
- Run `mason get` after adding or changing bricks.

## Agent Tips
- Check for nested `AGENTS.md` files in subdirectories.
- Respect package boundaries; avoid cross-package imports.
- Update documentation only when requested.
- Do not run destructive git commands without user request.
- Do not commit changes unless explicitly asked.

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **web-terminal** (12977 symbols, 28316 relationships, 300 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> If any GitNexus tool warns the index is stale, run `npx gitnexus analyze` in terminal first.

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `gitnexus_impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `gitnexus_detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `gitnexus_query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `gitnexus_context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `gitnexus_impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `gitnexus_rename` which understands the call graph.
- NEVER commit changes without running `gitnexus_detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/web-terminal/context` | Codebase overview, check index freshness |
| `gitnexus://repo/web-terminal/clusters` | All functional areas |
| `gitnexus://repo/web-terminal/processes` | All execution flows |
| `gitnexus://repo/web-terminal/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
