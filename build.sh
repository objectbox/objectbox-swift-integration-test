#!/usr/bin/env bash
set -eu

# build.sh: create

original_args="$*"

version="" # Podfile option
source="" # Podfile source

podfile_only=""

while [ $# -ge 1 ]; do
    case $1 in
    -h|help|--help|usage)
        echo "Usage: build.sh [options] {project-directory}"
        echo
        echo "  -v, --version: specify version for the Podfile"
        echo "  -s, --source: specify source repository for the Podfile"
        echo "  -S, --staging: use the staging source repository for the Podfile"
        echo "  -p, --podfile: only create Podfile"
        exit 0
        ;;
    -v|--version)
        shift
        version="$1"
        ;;
    -s|--source)
        shift
        source="$1"
        ;;
    -S|--staging)
        source="https://github.com/objectbox/objectbox-swift-spec-staging.git"
        ;;
    -p|--podfile)
        podfile_only="true"
        ;;
    *) break     # Unknown option for this stage, stop parsing here
        ;;
    esac
    shift
done

#macOS's readlink does not have -f option, do this instead:
script_dir=$( cd "$(dirname "$0")" ; pwd -P )

cd "$script_dir" # allow to call from any dir

if [ -z "${1-}" ]; then # No params, so loop over dirs and call this script with those
  echo "Invoking projects using original args: $original_args"
  for project in "$script_dir"/*/ ; do (./build.sh $original_args "$(basename "${project}")"); done
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
" > Podfile

if [ -n "${source}" ]; then
  echo "Using source repository: ${source}"
  echo "source '${source}'
" >> Podfile
fi

echo "target '${project}' do
  use_frameworks!

  # Pods for ${project}" >> Podfile

if [ -n "${version}" ]; then
  echo "Using version: ${version}"
  echo "  pod 'ObjectBox', '${version}'" >> Podfile
else
  echo "  pod 'ObjectBox'" >> Podfile
fi

if [ -d "${project}Tests" ]; then 
  echo "
  target '${project}Tests' do
    inherit! :search_paths
  end" >> Podfile
fi

echo "
end" >> Podfile

if [ -n "${podfile_only}" ]; then
  exit
fi

pod repo update
pod install
Pods/ObjectBox/setup.rb --replace-modified

xcodebuild clean build "${options[@]}"

if [ -d "${project}Tests" ]; then 
  xcodebuild test "${options[@]}" -destination 'platform=iOS Simulator,name=iPhone 11'
fi
