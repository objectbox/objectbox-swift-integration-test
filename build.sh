#!/usr/bin/env bash
set -eu

version="" # Podfile option
source="" # Podfile source

podfile_only=""
do_clean=""
use_carthage=""

while [ $# -ge 1 ]; do
    case $1 in
    -h|help|--help|usage)
        echo "Usage: $(basename "$0") [options] {project-directory}"
        echo
        echo "  -v, --version:  specify version for the Podfile"
        echo "  -s, --source:   specify source repository for the Podfile"
        echo "  -S, --staging:  use the staging source repository for the Podfile"
        echo "  -p, --podfile:  only create Podfile"
        echo "  -c, --carthage: use Carthage instead of CocoaPods"
        echo "  --clean:        cleans all added/modified files to reset the state to a fresh"
        echo "                  git checkout. Warning: Data may be LOST!!"
        echo "                  Does something like 'git clean -fdx && git reset --hard'"
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
    -c|--carthage)
        use_carthage="true"
        ;;
    --clean)
        do_clean="true"
        ;;
    *) break     # Unknown option for this stage, stop parsing here
        ;;
    esac
    shift
done

#macOS's readlink does not have -f option, do this instead:
script_dir=$( cd "$(dirname "$0")" ; pwd -P )

cd "$script_dir" # allow to call from any dir

if [ -n "$do_clean" ]; then
  echo "Cleaning..."
  git clean -fdx
  git reset --hard
fi

cocoapods_version=$(pod --version 2>/dev/null || true)
carthage_version=$(carthage version 2>/dev/null || true)

if [ -z "${1-}" ]; then # No tailing "project" param, so loop over dirs and call this script with those
  echo "Detected versions: CocoaPods ${cocoapods_version:-N/A}, Carthage ${carthage_version:-N/A}"

  # Original args ($@) are gone as we called shift during parsing.
  # Also, cannot capture original args as string as we need to preserve spaces, i.e. in version values.
  additional_args=""
  if [ -n "${podfile_only}" ]; then
      additional_args+=" --podfile"
  fi
  if [ -n "${use_carthage}" ]; then
      additional_args+=" --carthage"
  fi
  # Note: we do not need to propagate --clean flag
  echo "Invoking projects using args: -v \"$version\" -s \"$source\" $additional_args"
  for project in "$script_dir"/*/ ; do
      bash "$(basename "$0")" -v "$version" -s "$source" $additional_args "$(basename "${project}")"
  done
  echo "ALL DONE"
  exit
fi

project="$1"

echo "========================================================================="
echo "Building ${project}"
echo "========================================================================="

options=(CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS= CODE_SIGNING_ALLOWED=NO ENABLE_BITCODE=NO)
options+=(-derivedDataPath ./DerivedData -scheme "${project}")

cd "${project}"

if [ -n "$use_carthage" ]; then # --------------------- Carthage ---------------------
  xcodefile="project.pbxproj" # XCode project file
  xcodefile_carthage="project.pbxproj.4carthage" # XCode project file with changes "done by user" after "carthage update"

  if [ ! -f "$xcodefile_carthage" ]; then
    echo "No $xcodefile_carthage file, skipping..."
    exit 0
  fi

  echo "github \"objectbox/objectbox-swift\"" > Cartfile
  carthage update

  xcodeproj_dir=$(find -- *.xcodeproj -maxdepth 0)
  mv "$xcodeproj_dir/$xcodefile" "$xcodeproj_dir/$xcodefile.bak"
  cp "$xcodefile_carthage" "$xcodeproj_dir/$xcodefile"

  Carthage/Build/Mac/OBXCodeGen.framework/setup.rb

  options+=(-project "$xcodeproj_dir")

else # --------------------- CocoaPods ---------------------
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

  # On fresh CocoaPods installations (never did 'pod install' before; CI!), CocoaPods 1.8.[0-3] `pod repo update` fails.
  # https://github.com/CocoaPods/CocoaPods/issues/9226
  # To workaround this, use 'pod install --repo-update' instead
  if [[ "$cocoapods_version" > "1.8.3" ]]; then
    pod repo update
  else
    pod install --repo-update
  fi

  if test -f "Podfile.lock"; then
    echo "Podfile.lock exist, will use 'pod update' instead of 'pod install'"
    pod update
    Pods/ObjectBox/setup.rb --replace-modified
  else
    pod install
    Pods/ObjectBox/setup.rb
  fi

  options+=(-workspace "${project}.xcworkspace")

fi # End CocoaPods

xcodebuild clean build "${options[@]}"

if [ -d "${project}Tests" ]; then 
  xcodebuild test "${options[@]}" -destination 'platform=iOS Simulator,name=iPhone 11'
fi
