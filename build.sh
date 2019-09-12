#!/usr/bin/env bash
set -eu

project=$1

echo "========================================================================="
echo "Building ${project}"
echo "========================================================================="

options="CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS= CODE_SIGNING_ALLOWED=NO ENABLE_BITCODE=NO"
options="${options} -derivedDataPath ./DerivedData"
options="${options} -workspace ${project}.xcworkspace -scheme ${project}"

cd ${project}

# https://swift.objectbox.io/install
echo "
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

source 'https://github.com/objectbox/objectbox-swift-spec-staging.git'

target '${project}' do
  use_frameworks!

  # Pods for ${project}
  pod 'ObjectBox', '1.0.0-rc.3'
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
Pods/ObjectBox/setup.rb

xcodebuild clean build ${options}

if [ -d "${project}Tests" ]; then 
  xcodebuild test ${options} -destination 'platform=iOS Simulator,name=iPhone Xs'
fi
