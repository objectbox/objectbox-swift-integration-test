# ObjectBox Swift SDK Integration Tests

- IntTestiOSEmpty  
  - Tests setup and generator works on an empty iOS project.
- IntTestiOSOneEntity
  - Tests generator works for an iOS project if there is a single entity class.
- IntTestiOSRegular
  - Tests generator works for various entity classes, including relations, tests the database library works on iOS using unit tests.
- IntTestiOSRegularSPM
  - Like IntTestiOSRegular, but only to test the database library included in the Swift Package
    works on iOS using unit tests. Note: for Xcode projects, the ObjectBox Swift command plugin
    can only be run through the Xcode UI. So if there are changes to model JSON file or generated
    code, this needs to be done manually and committed.
- IntTestiOSUpdate
  - Tests generator works if an entity class is changed (with existing model JSON file and generated code file).
- IntTestiOSXcode16
  - Tests generator detects all source files for an Xcode 16 project that uses "buildable folders" and groups.
- IntTestmacOSOneEntity
  - Like IntTestiOSOneEntity, but for a macOS project.
- Test With Spaces
  - Tests setup and generator works for a project with spaces in the project path.

## How to run the tests

With `test.sh` you can run several integration tests for:

- the CocoaPods release (ObjectBox pod)
- the SwiftPM release (ObjectBox Swift Package)
- the Carthage release (deprecated, to be removed)

To test the latest CocoaPods release, simply run the script without any parameters:

```
./test.sh
```

To test only a specific project:

```
./test.sh IntTestiOSRegular
```

To test a particular CocoaPods release with a clean state (⚠️ `--clean` **resets any changes in this repo**):

```
./test.sh --clean --version 1.6.0
```

To test a CocoaPods release from the [staging repo](https://github.com/objectbox/objectbox-swift-spec-staging):

```
./test.sh --clean --version 4.3.1-rc1 --staging
```

To test a Swift Package release:

```
# Note: version can also be a branch
./test.sh --clean --swiftpm --version 4.3.0-beta.2
```

To test the Swift Package from the internal repo:

```
# Note: version can also be a tag
./test.sh --clean --swiftpm --version main --source https://<GITLAB_URL>/objectbox/objectbox-swift-spm.git
```

If all works out you should see something like this in your Terminal:

```
** TEST SUCCEEDED **

    _
_  //  ALL DONE (Thu Feb 25 11:43:58 CET 2021)
\X/
```

To learn more about the test script, use the `--help` parameter, which prints something like this:

```
$ ./test.sh --help
Usage: test.sh [options] {project-directory}

-v, --version:  The ObjectBox pod or Carthage version or Swift Package repository tag or branch
-s, --source:   The source repository for the Podfile/Cartfile or the Swift Package repository URL
-S, --staging:  use the staging source repository for the Podfile/Cartfile
-f, --file:     only create Podfile/Cartfile
-c, --carthage: Test the Carthage instead of the CocoaPods release
--carthage-bin: use the packaged Carthage executable from our bin dir
--swiftpm:      Test the SwiftPM instead of the CocoaPods release
--clean:        cleans all added/modified files to reset the state to a fresh
                git checkout. Warning: Data may be LOST!!
                Does something like 'git clean -fdx && git reset --hard'
--skip:         specify a project to skip
--framework:    specify a HTTPS URL to an uploaded framework to be tested
                (this creates a local Cartfile pointing to the URL)
```

## What is this doing?

When testing the CocoaPods release, the process for each project is like this:

1. Plain Xcode project and sources checked in without pods; ensure this "fresh" state when running on the CI machine
2. Add ObjectBox pods by running the usual commands as described in the docs (pod init, manual Podfile edits, pod install, setup.rb)
3. Build the project and its unit tests and run the latter

This is an example Podfile for a project called "obxtest2":

```
source 'https://github.com/objectbox/objectbox-swift-spec-staging.git'

# Uncomment the next line to define a global platform for your project
# platform :ios, '11.0'

target 'obxtest2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for obxtest2
  pod 'ObjectBox', '~> 1.5.0'

end
```

To get to a Podfile like that (and use it) consider this sequence:

0. Ensure no pod related files are on the file system (e.g. left-overs from last run)
1. `cd` into the project dir and run `pod init` to get an initial Podfile for the given project
2. Adjust the Podfile 
    1. Insert `source 'https://github.com/objectbox/objectbox-swift-spec-staging.git'` as the first line
    2. Find the line containing `  # Pods ` and insert `pod 'ObjectBox', '~> 1.0.0-rc.3'` after it
3. Run `Pods/ObjectBox/setup.rb` (still in the project dir)
4. Now that the pods are prepared for the project, build the project using the Xcode workspace

TODO: add unit tests to the plain Xcode projects and execute them in CI