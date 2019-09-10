ObjectBox Swift Integration Test
================================

The process for each project is like this:

1. Plain Xcode project and sources checked in without pods; ensure this "fresh" state when running on the CI machine
2. Add ObjectBox pods by running the usual commands as described in the docs (pod install, setup.rb)
3. Build the project and its unit tests and run the latter
