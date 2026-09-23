# AGENTS.md - ObjectBox Swift Integration Tests

## Project overview

Integration tests for the **ObjectBox Swift SDK**. The repo holds small Xcode/Swift projects and a shell runner
(`test.sh`) that adds ObjectBox to each project the way a user would (CocoaPods, SwiftPM or Carthage), runs the
ObjectBox code generator, builds and runs the unit tests. It verifies that a *released* ObjectBox version integrates
correctly; it does not build ObjectBox itself.

`README.md` is the human-facing documentation. Keep it in sync when changing `test.sh` flags or projects.

## Environment requirements

- **macOS only.** `test.sh` needs `xcodebuild`, `xcrun simctl` and BSD `sed -i ''`. It cannot run on Linux; changes
  made on a Linux machine can only be verified via CI.
- **CocoaPods mode:** a `pod` binary on the PATH. `.ruby-version` pins Ruby 3.2.7 for rbenv users. CI passes
  `--default-ruby`, which deletes `.ruby-version` so the runner's default Ruby is used, and installs CocoaPods via
  `sudo gem install cocoapods`.
- **SwiftPM mode:** Swift 5.9+ toolchain (see `swift-tools-version` in `.templates/`). The generator plugin needs
  network access (`--allow-network-connections all`).
- **Carthage mode:** `carthage` on the PATH, or `--carthage-bin` to use the bundled `bin/carthage` (x86_64 binary from
  2021). Carthage is deprecated and not tested in CI.
- **iOS simulator:** the script prefers a device named "iPhone 11", falls back to the first available iPhone and as a
  last resort to "iPhone 16". CI creates and boots a device named "iPhone 11" before checkout because Xcode 26 dropped
  it.

## Repository layout

```
├── test.sh                    # Test runner; loops over all project directories when called without a project
├── README.md                  # Human-facing docs
├── AGENTS.md                  # This file
├── .circleci/config.yml       # Primary CI (matrix over Xcode versions)
├── .gitlab-ci.yml             # Secondary CI (single macOS runner)
├── .gitlab/merge_request_templates/Default.md
├── .gitignore                 # Deliberately ignores generated code, Podfiles etc. (see "Conventions")
├── .ruby-version              # Ruby 3.2.7 for rbenv
├── .templates/
│   ├── Package.swift          # Package manifest used to build a project with swift tools (no test target)
│   └── PackageWithTest.swift  # Same, with a test target (used when <Project>Tests/ exists)
├── bin/carthage               # Bundled Carthage executable (deprecated)
├── IntTest*/                  # Test projects (one directory each)
└── Test With Spaces/          # Test project too (does not match the IntTest* pattern on purpose)
```

Created at runtime and not committed:

- `obx-swift-package/` - clone of the ObjectBox Swift Package (SwiftPM mode). The project loop skips it.
- `objectbox-framework-spec.json` - Carthage binary spec written by `--framework`.
- Per project: `Podfile`, `Pods/`, `*.xcworkspace`, `Cartfile*`, `Carthage/`, `Package.swift`, `.build/`,
  `DerivedData/`, `generated/`, `model-*.json`.

## Test projects

| Project                 | Purpose                                                                                           |
|-------------------------|---------------------------------------------------------------------------------------------------|
| `IntTestiOSEmpty`       | Setup and generator on an iOS project without entities (has one empty class so SwiftPM can build) |
| `IntTestiOSOneEntity`   | Generator with a single entity class                                                              |
| `IntTestiOSRegular`     | Various entities (classes, structs, ToOne, ToMany, backlinks, many-to-many), queries, Sync dry run; unit tests |
| `IntTestiOSRegularSPM`  | Copy of `IntTestiOSRegular` whose Xcode project references the Swift Package; SwiftPM mode only   |
| `IntTestiOSUpdate`      | Generator with an *existing* model JSON, generated file and `Podfile.lock` (update scenario)      |
| `IntTestiOSXcode16`     | Generator finds sources in an Xcode 16 project using "buildable folders" (SwiftUI app, iOS 18.2)  |
| `IntTestmacOSOneEntity` | Single entity in a macOS command line tool                                                        |
| `Test With Spaces`      | Setup and generator with spaces in the project path (test target contains only template tests)   |

Project specific notes:

- **IntTestiOSRegular and IntTestiOSRegularSPM share their sources.** The entity files are identical and the test
  file differs only in the `@testable import` line. Change both when changing one.
- **IntTestiOSRegularSPM** is the only project with a shared Xcode scheme (`IntTestiOSRegularSPMTests`) and the only
  project whose `project.pbxproj` references the package clone via `XCLocalSwiftPackageReference "../obx-swift-package"`.
  It is skipped in CocoaPods and Carthage mode.
- **IntTestiOSUpdate** is the only project that tracks `Podfile`, `Podfile.lock`, `*.xcworkspace`, `generated/` and
  `model-*.json` in git (force-added, they are gitignored). That is what it tests. When a `Podfile.lock` exists,
  `test.sh` runs `pod update` and `setup.rb --replace-modified` instead of `pod install` and `setup.rb`.
- **IntTestiOSXcode16** is skipped when the loop runs on Xcode < 16. Passing it explicitly runs it regardless.
- **IntTestiOSRegular** and **IntTestmacOSOneEntity** are the only projects with a `project.pbxproj.4carthage`; all
  other projects are skipped in Carthage mode.

## Running tests

```bash
./test.sh                                    # CocoaPods, latest release, all projects
./test.sh IntTestiOSRegular                  # Single project
./test.sh --clean --version 5.2.0            # Specific pod version, fresh checkout state
./test.sh --clean --version 5.2.0-sync       # Sync variant
./test.sh --clean --staging --version X.Y.Z-rc1   # CocoaPods staging spec repo
./test.sh --clean --swiftpm --version 5.2.0  # Swift Package tag (or branch)
./test.sh --clean --swiftpm --version main --source https://<GITLAB_URL>/objectbox/objectbox-swift-spm.git
OBX_SWIFT_FLAGS="-DOBJECTBOX_SYNC_ON -DOBJECTBOX_VERSION_5_2" ./test.sh --clean --version 5.2.0-sync
```

All flags (`./test.sh --help`):

| Flag                       | Effect                                                                                          |
|----------------------------|-------------------------------------------------------------------------------------------------|
| `-v, --version <ver>`      | Pod/Carthage version, or Swift Package tag/branch. Suffix `-sync` selects the Sync build.        |
| `-s, --source <src>`       | Podfile source repo, Cartfile binary spec URL, or Swift Package git URL. Not with `--staging`/`--framework`. |
| `-S, --staging`            | CocoaPods/Carthage staging spec repo. **No effect in SwiftPM mode** (use `--source`).           |
| `-f, --file`               | Only write the Podfile/Cartfile, then exit. No effect in SwiftPM mode.                          |
| `-c, --carthage`           | Carthage instead of CocoaPods.                                                                  |
| `--carthage-bin`           | Carthage using the bundled `bin/carthage`.                                                      |
| `--framework <url>`        | Carthage with a local binary spec pointing at this URL (for testing an uploaded xcframework).   |
| `--swiftpm`                | SwiftPM instead of CocoaPods.                                                                   |
| `--clean`                  | `git clean -fdx && git reset --hard` on the whole repo, once, before running. **Destroys local changes.** |
| `--skip <project>`         | Skip one project (only one value is supported).                                                 |
| `--default-ruby`           | Delete `.ruby-version` so rbenv's default Ruby is used (CI).                                    |
| `<project>`                | Positional: run only this project directory. Without it, the script re-invokes itself per directory. |

Environment variable **`OBX_SWIFT_FLAGS`**: appended to `OTHER_SWIFT_FLAGS` for `xcodebuild` (CocoaPods, Carthage and
the IntTestiOSRegularSPM xcodebuild run). It is *not* passed to `swift build`/`swift test`. Defines used by the tests:

- `OBJECTBOX_SYNC_ON` / `OBJECTBOX_SYNC_OFF` - `testDrySync()` asserts `Sync.isAvailable()` accordingly. Without either
  define the test only prints the result.
- `OBJECTBOX_VERSION_5_2` - enables code that needs API introduced in ObjectBox 5.2 (e.g. `SyncChangeListener`).

### What test.sh does per mode

**CocoaPods (default):** writes a fresh `Podfile` (`platform :ios, '15.0'`, or `:osx, '12.0'` if the project name
contains "macOS"; optional `source`; `pod 'ObjectBox', '<version>'`; a `<Project>Tests` target if that directory
exists; for macOS a `post_install` hook raising pod targets to macOS 12.0, see "Conventions"), runs `pod repo update`, `pod install` (or `pod update`), `Pods/ObjectBox/setup.rb`, then
`xcodebuild clean build` on `<Project>.xcworkspace` with scheme `<Project>` and code signing disabled, and
`xcodebuild test` on the iOS simulator if `<Project>Tests/` exists.

**SwiftPM:** clones the package repo (default `https://github.com/objectbox/objectbox-swift-spm.git`) into
`obx-swift-package/` at the given tag/branch (the `-sync` suffix is stripped for the clone), copies a template from
`.templates/` to `<Project>/Package.swift` (switching to `ObjectBox-Sync.xcframework` for `-sync`), then runs
`swift package reset`, `swift package update`, the `objectbox-generator` command plugin, `swift build` and
`swift test` on the host. The templates exclude iOS/macOS UI files so the Xcode projects can double as packages.
For **IntTestiOSRegularSPM** it additionally deletes `Package.swift`, moves the generated file to `generated/` and the
model JSON to the project root (where the Xcode project expects them), and runs `xcodebuild clean build` and `test`
with scheme `IntTestiOSRegularSPMTests` on the iOS simulator. This exists because neither adding a package to an Xcode
project nor running the generator plugin in Xcode can be scripted.

**Carthage (deprecated):** writes a `Cartfile` with `binary "<spec url>"` and `== <version>`, runs
`carthage update --use-xcframeworks`, swaps `project.pbxproj` for `project.pbxproj.4carthage` (backup `.bak`), runs
`Carthage/Build/Mac/OBXCodeGen.framework/setup.rb` and builds with `-project`.

## CI

Both CIs run `test.sh --clean` with explicit versions. See `docs/release-checklist.md` in the `objectbox-swift` repo
for how releases and staging releases are created.

**CircleCI** (`.circleci/config.yml`, primary): jobs `test-swiftpm` and `test-cocoapods`, each a matrix over Xcode
images (currently 16.4.0, 26.0.0, 26.1.1, 26.2.0, 26.3.0) on `m4pro.medium`. Each job first creates and boots an
"iPhone 11" simulator, then runs:

- SwiftPM: current version, current version `-sync`.
- CocoaPods: latest without version (log must be checked manually for the expected version), current version, current
  `-sync`, previous version, previous `-sync`.

On failure `.xcresult` bundles and simulator crash reports are stored as artifacts.

**GitLab CI** (`.gitlab-ci.yml`): jobs `swiftpm`, `swiftpm-sync`, `cocoapods-latest`, `cocoapods-sync-latest` on a
macOS runner (tags `xcode`, `mac`), serialized via `resource_group: ios-simulator`. The staging job
`.cocoapods-staging` is hidden (dot prefix) and only enabled temporarily when testing a staging release. The "no
version" and "previous version" runs are CircleCI-only because the GitLab runner is slow.

**Bumping the tested ObjectBox version** (the most common change in this repo, commit style `CI: test obx X.Y.Z`):

1. `.circleci/config.yml`: SwiftPM version and `-sync`, CocoaPods explicit and `-sync`; move the old version to the
   two "previous" steps if it was a final release.
2. `.gitlab-ci.yml`: the four active jobs.
3. If the release adds API the tests should exercise, add a new `-DOBJECTBOX_VERSION_X_Y` define to `OBX_SWIFT_FLAGS`
   in both CI configs and guard the new test code with it.

## Conventions

- **Do not commit generated or package-manager files.** `.gitignore` deliberately ignores `generated/`,
  `model-*.json`, `Podfile*`, `Pods/`, `Cartfile*`, `*.xcworkspace`, `Package.resolved`, `.build/` and `DerivedData/`
  so that each run proves they get created. `IntTestiOSUpdate` is the one intended exception. Untracked Podfiles in
  other project directories are leftovers from earlier runs; `test.sh` overwrites them.
- **Adding a test project:** every top-level directory except `bin/` and `obx-swift-package/` is treated as a project.
  The directory name must equal the Xcode scheme and app target name. Tests go in `<Project>Tests/` with a target of
  the same name. macOS projects need "macOS" in the name (Podfile platform selection). App/UI files must use one of
  the names excluded by the SwiftPM templates (`AppDelegate.swift`, `Assets.xcassets`, `Info.plist`,
  `ObxSwiftUiTestApp.swift`, `ViewController.swift`) or be added to both templates, otherwise `swift build` compiles
  them on macOS. A project needs at least one non-excluded Swift source file.
- **Deployment targets:** iOS 15.0 and macOS 11.0 everywhere (Podfile written by `test.sh`, package templates,
  `project.pbxproj`). Exceptions: `IntTestiOSXcode16` uses iOS 18.2, and `PackageWithTest.swift` uses macOS 12 for
  it. CocoaPods on macOS (`IntTestmacOSOneEntity` project and generated Podfile) uses macOS 12.0 because Xcode 27
  supports no lower target; as the ObjectBox podspec still declares osx 11.0, the generated Podfile raises pod targets
  to 12.0 in a `post_install` hook. Remove that workaround once the podspec in objectbox-swift requires macOS 12.0. All Xcode projects use the Xcode 16 format (`objectVersion = 77`).
- **Schemes:** only `IntTestiOSRegularSPM` ships a shared scheme. The other projects rely on `xcodebuild`
  auto-creating a scheme named after the app target.
- **Merge requests** use `.gitlab/merge_request_templates/Default.md` and reference issues as `objectbox-swift#NUMBER`.

## Code style

- Tests use XCTest with `@testable import <Project>`. Tests that touch the database open a `Store` in a fresh directory under
  Application Support and calls `closeAndDeleteAllFiles()` in `tearDown`.
- Entity classes intentionally mix both declaration styles: conformance to the `Entity` protocol (`Note`, `Foo`) and
  the `// objectbox:Entity` annotation (`Author`, `Teacher`, the structs). Relations covered: `ToOne`, standalone
  `ToMany`, backlink `ToMany` (`// objectbox: backlink = "..."`) and many-to-many.
- Source files carry an `ObjectBox Ltd.` copyright header.
