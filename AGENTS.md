# AGENTS.md - ObjectBox Swift Integration Tests

## Project Overview

This repository contains integration tests for the **ObjectBox Swift SDK**. It validates that ObjectBox works correctly when integrated via different package managers (CocoaPods, SwiftPM, Carthage) across various project configurations.

## Repository Structure

```
├── test.sh                    # Main test runner script
├── .gitlab-ci.yml             # GitLab CI configuration
├── .circleci/config.yml       # CircleCI configuration
├── .templates/                # Package.swift templates for SwiftPM testing
│   ├── Package.swift
│   └── PackageWithTest.swift
├── bin/                       # Bundled tools (e.g., Carthage)
└── IntTest*/                  # Integration test projects (see below)
```

## Test Projects

| Project                 | Purpose                                                                          |
|-------------------------|----------------------------------------------------------------------------------|
| `IntTestiOSEmpty`       | Tests setup/generator on an empty iOS project                                    |
| `IntTestiOSOneEntity`   | Tests generator with a single entity class                                       |
| `IntTestiOSRegular`     | Full tests with various entities, relations, and unit tests (CocoaPods/Carthage) |
| `IntTestiOSRegularSPM`  | Like IntTestiOSRegular but for SwiftPM with Xcode project                        |
| `IntTestiOSUpdate`      | Tests generator with existing model JSON and generated code                      |
| `IntTestiOSXcode16`     | Tests generator with Xcode 16 "buildable folders" feature                        |
| `IntTestmacOSOneEntity` | Single entity test for macOS                                                     |
| `Test With Spaces`      | Tests projects with spaces in path                                               |

## Running Tests

### CocoaPods (default)
```bash
./test.sh                              # Latest release
./test.sh --version 5.1.1              # Specific version
./test.sh --staging --version X.Y.Z    # Staging repo
./test.sh IntTestiOSRegular            # Single project
```

### SwiftPM
```bash
./test.sh --swiftpm --version 5.1.1
./test.sh --swiftpm --version main --source https://github.com/objectbox/objectbox-swift-spm.git
```

### Key Flags
- `--clean` - Reset repo to fresh state (WARNING: destroys local changes)
- `--staging` - Use staging spec repo
- `--skip <project>` - Skip a specific project
- `--version <ver>` - Specify version/branch/tag

## CI/CD

- **CircleCI**: Primary CI, tests SwiftPM and CocoaPods (including Sync variants) across multiple Xcode versions
- **GitLab CI**: Tests SwiftPM and CocoaPods staging releases

## Package Manager Support

| Manager   | Regular ObjectBox | Sync ObjectBox                    |
|-----------|-------------------|-----------------------------------|
| CocoaPods | ✅ Tested          | ✅ Tested (version suffix `-sync`) |
| SwiftPM   | ✅ Tested          | ✅ Tested (version suffix `-sync`) |
| Carthage  | ⚠️ Deprecated     | N/A                               |

## Important Notes

- **Sync testing**: Both CocoaPods and SwiftPM test regular and Sync variants using the `-sync` version suffix (e.g., `5.1.1` and `5.1.1-sync`).
- **IntTestiOSRegularSPM**: Only runs with `--swiftpm` flag; skipped for CocoaPods/Carthage.
- **IntTestiOSXcode16**: Requires Xcode 16+; automatically skipped on older versions.
- **Ruby/CocoaPods**: Requires rbenv with version specified in `.ruby-version`.

## Code Style

- Swift test files use XCTest framework
- Entity classes demonstrate various ObjectBox features (ToOne, ToMany, queries, etc.)
