# Android Rootfs Implementation Plan

> **For agentic workers:** Execute the independent build and runtime tasks in parallel, then review requirements and code quality before device verification. Do not commit or publish without user authorization.

**Goal:** Ship configurable offline Alpine images with user `gao`, zsh, the requested tools, an explicit PRoot administrator session, and a repeatable documented maintenance workflow.

**Architecture:** One JSON asset defines user and package intent. A Linux container builder resolves and locks inputs separately from offline assembly, producing four images and their final hashes. Native initialization applies an additive configuration migration to existing installations instead of overlaying their rootfs. PRoot launches the configured numeric identity; administrator execution is explicit.

**Tech Stack:** Python standard library, Alpine apk, Docker/QEMU, Kotlin, Dart/Flutter, GitHub Actions.

## Task 1: Preserve the baseline

- [x] Confirm main baseline `c28539b` and preserve the existing draft guide.
- [x] Create implementation branch `codex/android-rootfs`.
- [x] Run existing offline artifact checks before changes: six passed.
- [x] Capture exact-device package metadata and 2,217 `/root` file checksums before installing the updated APK.

## Task 2: Build and lock customized rootfs images

**Owner:** build worker.

**Files:** `app_plugin/android_shell/rootfs/`, `scripts/build_rootfs.py`, focused builder tests, `android/src/main/assets/shell/rootfs-config.json`, and four `rootfs.tgz` assets.

- [x] Add the canonical user/package configuration and validate names, paths and supported schemas.
- [x] Implement explicit online dependency refresh, recording source hashes, resolved package versions and complete APK inputs.
- [x] Build lrzsz from pinned source with maintained Debian patches; native probe installed and executed `rz`/`sz`.
- [x] Implement offline assembly using the locked official minirootfs and verified local packages, without disabling package scripts.
- [x] Include an offline package repository with architecture aliases for additive upgrades and configuration metadata.
- [x] Export deterministic gzip/tar assets, record independent final hashes and verify their package/account contents.
- [x] Build all four ABIs and compare complete offline rebuilds: all four final SHA256 values matched exactly; 40 lrzsz quickchecks passed.

## Task 3: Configure default identity and migrate existing installations

**Owner:** runtime worker.

**Files:** Android shell Kotlin initialization/migration and tests, Dart environment and launch tests, Android host execution.

- [x] Verify PRoot identity behavior; use a separately launched root session because in-session `su` and setuid do not work on the target phone.
- [x] Read the same JSON asset for new and existing installs, with a separate configuration marker.
- [x] Add missing accounts/home/configuration idempotently, detecting UID conflicts and preserving existing rc files.
- [x] Implement missing-package installation from the staged offline repository through apk; device acceptance follows below.
- [x] Return configured guest identity/home/shell and use them consistently in PRoot flags, environment and working directory.
- [x] Support explicit root execution and `WEB_TERMINAL_USER=root` without slicing shell-launch argument tails.
- [x] Cover migration preservation, retries/conflicts, normal/root launch and system-shell fallback: 11 native and 9 Dart tests passed.

## Task 4: Connect verification and CI

**Owner:** parent.

**Files:** existing download/verification scripts, focused artifact tests, `.github/workflows/android-rootfs.yml`, scoped CI checks.

- [x] Prevent the native-component download helper from overwriting customized rootfs assets.
- [x] Connect configuration/recipe and final image checks independently of unchanged upstream input hashes; final asset run follows below.
- [x] Add packaging contract checks; five positive/negative fixtures passed.
- [x] Add a manual Linux build workflow exporting images, locks and reusable input archives for review; YAML parsing passed.
- [x] Keep ordinary releases as consumers of reviewed, checked-in images.

## Task 5: Review and verify delivery

- [x] Review each component against the accepted requirements, then review implementation quality and integration assumptions.
- [x] Run focused checks: Python 18/18, Kotlin 11/11 and Flutter 9/9; scoped analysis and isolated Dart formatting passed.
- [x] Build and inspect the release APK: all four configured images and all three Flutter ABI native dependency sets passed.
- [x] Upgrade the exact device `adb-37011FDH8119SS-iNurPr._adb-tls-connect._tcp` with `adb install -r`; verify gao/zsh/tools and explicit native root execution. All 2,217 original root file hashes and 52 existing packages were retained; two OpenSSL dependencies upgraded from 3.3.3-r0 to 3.3.7-r2.
- [x] Verify administrator selection and restoration through the actual Environment Variables settings UI on Pocket DS (`10.100.8.115:5555`): the new root terminal reports UID 0 and `/root`; removing the temporary setting restores UID 1000 and `/home/gao` for new sessions.
- [x] Verify repeated initialization on Pocket DS: two cold launches retain all 15 captured core/account/package/rc/probe hashes and launch gao/zsh. The two task-owned probe files were removed afterward.
- [x] Replace `docs/ANDROID_ROOTFS.md` draft with actual configuration, update/rebuild/verification, migration and administrator-session instructions.

Scoped baseline commands:

```sh
python3 -m unittest discover -s app_plugin/android_shell/scripts -p 'test_*.py' -v
cd app_plugin/android_shell
flutter test test/android_proot_launch_test.dart
```

The user has approved implementation. Additional design approval and automatic commits are not part of this execution.

Device evidence is kept locally under `build/android-rootfs/device-after/` for the Pixel Fold upgrade and `build/android-rootfs/pocket-ds/` for fresh installation, settings selection and repeated initialization. Pocket DS was used for the final UI checks at the user's request because another task was using the Pixel Fold.
