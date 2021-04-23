#!/usr/bin/env bash
set -eu

##### Used in Podfile/Cartfile #####
version=""
source=""

##### Behavioral flags #####
file_only=""
do_clean=""
use_carthage=""
use_staging=""
framework=""

skip_project=""
carthage_bin="carthage"

while [ $# -ge 1 ]; do
    case $1 in
    -h|help|--help|usage)
        echo "Usage: $(basename "$0") [options] {project-directory}"
        echo
        echo "  -v, --version:  specify version for the Podfile/Cartfile"
        echo "  -s, --source:   specify source repository for the Podfile/Cartfile"
        echo "  -S, --staging:  use the staging source repository for the Podfile/Cartfile"
        echo "  -f, --file:     only create Podfile/Cartfile"
        echo "  -c, --carthage: use Carthage instead of CocoaPods"
        echo "  --carthage-bin: use the packaged Carthage executable from our bin dir"
        echo "  --clean:        cleans all added/modified files to reset the state to a fresh"
        echo "                  git checkout. Warning: Data may be LOST!!"
        echo "                  Does something like 'git clean -fdx && git reset --hard'"
        echo "  --skip:         specify a project to skip"
        echo "  --framework:    specify a HTTPS URL to an uploaded framework to be tested"
        echo "                  (this creates a local Cartfile pointing to the URL)"
        exit 0
        ;;
    -v|--version)
        shift
        version="$1"
        ;;
    --framework)
        shift
        framework="$1"
        use_carthage="true"
        ;;
    -s|--source)
        shift
        source="$1"
        ;;
    -S|--staging)
        use_staging="true"
        ;;
    -f|--file)
        file_only="true"
        ;;
    -c|--carthage)
        use_carthage="true"
        ;;
    --carthage-bin)
        use_carthage="true"
        carthage_bin="bin/carthage"
        ;;
    --clean)
        do_clean="true"
        ;;
    --skip)
        shift
        skip_project="$1"
        ;;
    *) break     # Assuming project comes next, stop parsing here
        ;;
    esac
    shift
done

#Validation
if [ -n "${source}" ]; then
    if [ -n "$use_staging" ]; then
      echo "Cannot specify source AND staging; use -h for help"
      exit 1
    fi
    if [ -n "$framework" ]; then
      echo "Cannot specify source AND framework; use -h for help"
      exit 1
    fi
fi

#macOS's readlink does not have -f option, do this instead:
script_dir=$( cd "$(dirname "$0")" ; pwd -P )

cd "$script_dir" # allow to call from any dir

if [ -n "$do_clean" ]; then
  echo "Cleaning..."
  git clean -fdx
  git reset --hard
fi

if [ -n "$framework" ]; then
  source="$script_dir/objectbox-framework-spec.json"
  if [ -z "$version" ]; then  # didn't work without a version
    date=$(date '+%Y%m%d')
    version="0.0.0-dummy$date"
  fi
  echo "{ \"${version}\": \"${framework}\" }" > "$source"
fi

if [ -z "${1-}" ]; then # No tailing "project" param, so loop over dirs and call this script with those
  # Original args ($@) are gone as we called shift during parsing.
  # Also, cannot capture original args as string as we need to preserve spaces, i.e. in version values.
  additional_args=""
  if [ -n "${file_only}" ]; then
      additional_args+=" --file"
  fi
  if [ -n "${use_carthage}" ]; then
      additional_args+=" --carthage"
  fi
  if [ -n "$use_staging" ]; then
    additional_args+=" --staging"
  fi
  # Note: we do not need to propagate --clean flag
  echo "Invoking projects using args: -v \"$version\" -s \"$source\" $additional_args"
  for project in "$script_dir"/*/ ; do
    project_name="$(basename "${project}")"
    if [ "$project_name" == "bin" ]; then
      continue # Skip our bin/ dir
    fi
    if [ "$project_name" != "$skip_project" ]; then
      bash "$(basename "$0")" -v "$version" -s "$source" $additional_args "$project_name"
    else
      echo "Skipped $project"
    fi
  done
  echo "    _"
  echo " _ //  ALL DONE ($(date))"
  echo " \X/"
  echo
  exit
fi

project="$1"

echo "========================================================================="
echo "Building integration test project '${project}'"
echo "========================================================================="

options=(CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS= CODE_SIGNING_ALLOWED=NO ENABLE_BITCODE=NO)
options+=(-derivedDataPath ./DerivedData -scheme "${project}")

cd "${project}"

if [ -n "$use_carthage" ]; then # --------------------- Carthage ---------------------
  if [ -n "$use_staging" ]; then
    source="https://raw.githubusercontent.com/objectbox/objectbox-swift-spec-staging/master/cartspec/ObjectBox.json"
    echo "Using staging repo at $source"
  fi

  if [ -z "$source" ]; then
    source="https://raw.githubusercontent.com/objectbox/objectbox-swift/main/cartspec/ObjectBox.json"
  fi

  xcodefile="project.pbxproj" # XCode project file
  xcodefile_carthage="project.pbxproj.4carthage" # XCode project file with changes "done by user" after "carthage update"

  if [ ! -f "$xcodefile_carthage" ]; then
    echo "No $xcodefile_carthage file, skipping..."
    exit 0
  fi

  #echo "github \"objectbox/objectbox-swift\"" > Cartfile
  printf "binary \"%s\"" "$source" > Cartfile

  if [ -n "${version}" ]; then
    if [[ $version =~ ^[[:digit:]] ]]; then
      version="== $version" # Cartfile syntax for exact version
    fi
    echo "Using version: ${version}"
    echo " ${version}" >> Cartfile
  fi

  if [ -n "${file_only}" ]; then
    exit
  fi

  carthage_version=$($carthage_bin version 2>/dev/null || true)
  echo "Detected Carthage version ${carthage_version:-N/A}"

  $carthage_bin update

  xcodeproj_dir=$(find -- *.xcodeproj -maxdepth 0)
  mv "$xcodeproj_dir/$xcodefile" "$xcodeproj_dir/$xcodefile.bak"
  cp "$xcodefile_carthage" "$xcodeproj_dir/$xcodefile"

  Carthage/Build/Mac/OBXCodeGen.framework/setup.rb

  options+=(-project "$xcodeproj_dir")

else # --------------------- CocoaPods ---------------------
  if [ -n "$use_staging" ]; then
    source="https://github.com/objectbox/objectbox-swift-spec-staging.git"
  fi

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

  if [ -n "${file_only}" ]; then
    exit
  fi

  pod_bin="$(which pod)"

  # Apply M1 workaround if needed
  set +e
  $pod_bin install &> /dev/null
  if [ $? -ne 0 ]; then
   if [[ $(uname -p) == 'arm' ]]; then
      echo "Make sure you have CocoaPods installed and dependencies up to date (see https://github.com/CocoaPods/CocoaPods/issues/9907#issuecomment-817394413)"
      echo "Ensure you have a working CocoaPods setup for your Ruby installation, e.g. by running:"
      echo "gem update ffi ethon"
      echo ""
      echo "Alternatively install CocoaPods using homebrew by running:"
      echo "brew install cocoapods"
      echo ""

      # try x86_64 version as last resort
      pod_bin="arch -x86_64 $pod_bin"
   fi
  fi
  set -e

  cocoapods_version=$($pod_bin --version 2>/dev/null || true)
  echo "Detected CocoaPods version ${cocoapods_version:-N/A}"

  # On fresh CocoaPods installations (never did 'pod install' before; CI!), CocoaPods 1.8.[0-3] `pod repo update` fails.
  # https://github.com/CocoaPods/CocoaPods/issues/9226
  # To workaround this, use 'pod install --repo-update' instead
  if [[ "$cocoapods_version" > "1.8.3" ]]; then
    $pod_bin repo update
  else
    $pod_bin install --repo-update
  fi

  if test -f "Podfile.lock"; then
    echo "Podfile.lock exist, will use 'pod update' instead of 'pod install'"
    $pod_bin update
    Pods/ObjectBox/setup.rb --replace-modified
  else
    $pod_bin install
    Pods/ObjectBox/setup.rb
  fi

  options+=(-workspace "${project}.xcworkspace")

fi # End CocoaPods

xcodebuild clean build "${options[@]}"

if [ -d "${project}Tests" ]; then 
  xcodebuild test "${options[@]}" -destination 'platform=iOS Simulator,name=iPhone 11'
fi
