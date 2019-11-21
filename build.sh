#!/usr/bin/env bash
set -eu

#script_dir=$(dirname "$(readlink -f "$0")")
#macOS's readlink does not have -f option, do this instead:
script_dir=$( cd "$(dirname "$0")" ; pwd -P )

cd "$script_dir" # allow to call from any dir

if [ -z "${1-}" ]; then # No params, so loop over dirs and call this script with those
  for project in "$script_dir"/*/ ; do (./build.sh "$(basename "${project}")"); done
  echo "ALL DONE"
  exit
fi

project="$1"

echo "========================================================================="
echo "Building ${project}"
echo "========================================================================="

options=(CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS= CODE_SIGNING_ALLOWED=NO ENABLE_BITCODE=NO)
options+=(-derivedDataPath ./DerivedData)
options+=(-workspace "${project}.xcworkspace" -scheme "${project}")

cd "${project}"

# https://swift.objectbox.io/install
echo "
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

#source 'https://github.com/objectbox/objectbox-swift-spec-staging.git'

target '${project}' do
  use_frameworks!

  # Pods for ${project}
  pod 'ObjectBox'
" > Podfile

if [ -d "${project}Tests" ]; then 
  echo "
  target '${project}Tests' do
    inherit! :search_paths
  end" >> Podfile
fi

echo "
end" >> Podfile

pod repo update
pod install
Pods/ObjectBox/setup.rb --replace-modified

xcodebuild clean build "${options[@]}"

if [ -d "${project}Tests" ]; then 
  xcodebuild test "${options[@]}" -destination 'platform=iOS Simulator,name=iPhone Xs'
fi
