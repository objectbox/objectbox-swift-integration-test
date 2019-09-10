ObjectBox Swift Integration Test
================================

The process for each project is like this:

1. Plain Xcode project and sources checked in without pods; ensure this "fresh" state when running on the CI machine
2. Add ObjectBox pods by running the usual commands as described in the docs (pod init, manual Podfile edits, pod install, setup.rb)
3. Build the project and its unit tests and run the latter

This is an example Podfile for a project called "obxtest2":

```
source 'https://github.com/objectbox/objectbox-swift-spec-staging.git'

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'obxtest2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for obxtest2
  pod 'ObjectBox', '~> 1.0.0-rc.3'

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