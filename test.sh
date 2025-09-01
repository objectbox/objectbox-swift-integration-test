#!/usr/bin/env bash
set -eu

# This script triggers the integration tests, e.g. by running 'xcodebuild' or 'swift' (SPM).
# If no project directory is given as parameter, this script calls itself for each test directory in a for loop.

version=""

##### Used in Podfile/Cartfile or as the Swift Package repo #####
source=""

##### Behavioral flags #####
file_only=""
do_clean=""
use_carthage=""
use_swiftpm=""
use_staging=""
framework=""

skip_project=""
carthage_bin="carthage"

# Note: do not use the repo name, 'objectbox-swift-spm', it may accidentally use a different directory than intended
swift_package_dir="obx-swift-package"

while [ $# -ge 1 ]; do
    case $1 in
    -h|help|--help|usage)
        echo
        echo "Usage: $(basename "$0") [options] {project-directory}"
        echo
        echo "  -v, --version <version>  Set the ObjectBox pod or Carthage version or Swift Package repository tag or branch to test"
        echo "  -s, --source <source>    Set the source repository for the Podfile/Cartfile or the Swift Package repository URL"
        echo "  -S, --staging            Use our staging source repository for the Podfile/Cartfile"
        echo "  -f, --file               Only create the Podfile/Cartfile"
        echo "  -c, --carthage           Test the Carthage instead of the CocoaPods release"
        echo "  --carthage-bin           Use the packaged Carthage executable from our bin dir"
        echo "  --framework <url>        Test the framework uploaded to this HTTPS URL instead of the CocoaPods release"
        echo "                           (this creates a local Cartfile pointing to the URL)"
        echo "  --swiftpm                Test the SwiftPM instead of the CocoaPods release"
        echo "  --clean                  Cleans all added/modified files to reset the state to a fresh"
        echo "                           git checkout. Warning: Data may be LOST!!"
        echo "                           Does something like 'git clean -fdx && git reset --hard'"
        echo "  --skip <project>         Skip the given project"
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
    --swiftpm)
        use_swiftpm="true"
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

if [ -n "${use_carthage}" ] && [ -n "${use_swiftpm}" ]; then
  echo "Cannot combine carthage AND Swift PM; use -h for help"
  exit 1
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

########################################################################################################
#### If no project parameter was given, loop over project directories and call this script for each ####
########################################################################################################
if [ -z "${1-}" ]; then
  # Original args ($@) are gone as shift was called during parameter parsing above.
  # Also, cannot capture original args as string as spaces need to be preserved, i.e. in version values.
  additional_args=""
  if [ -n "${file_only}" ]; then
      additional_args+=" --file"
  fi
  if [ -n "${use_carthage}" ]; then
      additional_args+=" --carthage"
  fi
  if [ -n "${use_swiftpm}" ]; then
      additional_args+=" --swiftpm"
  fi
  if [ -n "$use_staging" ]; then
    additional_args+=" --staging"
  fi
  # Note: no need to propagate --clean flag, doing it once on the root directory is enough
  echo "Invoking projects using args: -v \"$version\" -s \"$source\" $additional_args"
  for project in "$script_dir"/*/ ; do
    project_name="$(basename "${project}")"
    if [ "$project_name" == "bin" ]; then
      continue # Skip the bin/ dir
    fi
    if [ "$project_name" == "$swift_package_dir" ]; then
      continue # Skip the Swift Package itself, it is not an integration test project
    fi

    # Skip IntTestiOSXcode16 when the current Xcode version is smaller than 16
    # Xcode 16 projects default to 'Buildable Folders' which are not backwards
    # compatible with Xcode 15.* versions. Skipping the IntTestiOSXcode16 project
    # ensures that the pipelines pass when executed on runners with Xcode version < 16
    if [ "$project_name" == "IntTestiOSXcode16" ]; then
      xcode_version=$(xcodebuild -version | grep "Xcode" | awk '{print $2}' | cut -d. -f1)
      if [ "$xcode_version" -lt 16 ]; then
        echo "Skipped $project_name due to Xcode version $xcode_version"
        continue
      fi
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
fi # end of "project loop"

###############################################################################
#### A project parameter was given (by the user or the project loop above) ####
###############################################################################
project="$1"

if [ -n "${use_swiftpm}" ]; then
  # Check out the Swift Package version once for all projects that should be tested

  # If source is not set, use the GitHub repo URL
  if [ -z "$source" ]; then
    source="https://github.com/objectbox/objectbox-swift-spm.git"
  fi

  # TODO Only do this once if called for multiple projects (issues: this script calls itself; this script may be called
  #  multiple times with different versions; CI does not remove this as it's a Git repo).
  echo "Checking out ObjectBox Swift Package from $source at branch/tag $version"
  rm -rf "$swift_package_dir"
  git clone --depth 1 --branch "$version" "$source" "$swift_package_dir"
fi

cd "${project}"
[ -d "${project}Tests" ] && project_has_tests=true || project_has_tests=false

echo "========================================================================="
echo "Building integration test project '${project}' (tests: $project_has_tests)"
echo "========================================================================="

if [ -n "${use_swiftpm}" ]; then # --------------------- SwiftPM ---------------------
  # Note: the below assumes the Swift Package is checked out in the same directory as this script,
  # this is done once for all projects, see above.

  # Make the existing test projects into Swift Package projects by adding a Package file,
  # then build and run tests using swift tools instead of xcodebuild.
  # This only works because the Package file excludes iOS/macOS (UI) app specific files.
  if [ $project_has_tests == "true" ]; then
      template_name="PackageWithTest.swift"
  else
      template_name="Package.swift"
  fi
  cp "$script_dir/.templates/$template_name" Package.swift
  sed -i '' "s|\${PROJECT_DIR}|$project|g" Package.swift

  swift --version
  swift package reset
  #swift package purge-cache
  swift package update
  swift package plugin --allow-writing-to-package-directory --allow-network-connections all objectbox-generator --target "$project"
  swift build
  if [ -d "${project}Tests" ]; then
    echo "Testing SwiftPM project $project..."

    # Execute unit tests on the host machine
    swift test
  fi
  
  if [ "$project" == "IntTestiOSRegularSPM" ]; then
    echo "Running tests on iOS simulator for IntTestiOSRegularSPM project..."
    # IntTestiOSRegularSPM contains an Xcode iOS app project (as Swift Package projects can currently not run tests on
    # an iOS simulator) with the ObjectBox Swift Package manually added as a dependency (as there currently is no way to
    # script this).
    # Also note that typically a user would run the generator by running the ObjectBox Swift command plugin from the
    # Xcode UI. As this is also not possible via script, take the generated files from when treating this project as a
    # Swift Package project above.

    # Delete Package file to avoid confusing xcodebuild
    rm Package.swift
    # Steal files generated using swift tools above
    mkdir generated
    mv IntTestiOSRegularSPM/generated/EntityInfo-IntTestiOSRegularSPM.generated.swift ./generated/
    mv IntTestiOSRegularSPM/model-IntTestiOSRegularSPM.json .
    xcodebuild -scheme 'IntTestiOSRegularSPMTests' test -destination 'platform=iOS Simulator,name=iPhone 11'
  fi

elif [ "$project" == "IntTestiOSRegularSPM" ]; then
  echo "Skip IntTestiOSRegularSPM for CocoaPods/Carthage, only supported when using --swiftpm option"

else # --------------------- CocoaPods or Carthage ---------------------
  options=(CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS= CODE_SIGNING_ALLOWED=NO ENABLE_BITCODE=NO)
  options+=(-derivedDataPath ./DerivedData -scheme "${project}")

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

    $carthage_bin update --use-xcframeworks

    xcodeproj_dir=$(find -- *.xcodeproj -maxdepth 0)
    mv "$xcodeproj_dir/$xcodefile" "$xcodeproj_dir/$xcodefile.bak"
    cp "$xcodefile_carthage" "$xcodeproj_dir/$xcodefile"

    Carthage/Build/Mac/OBXCodeGen.framework/setup.rb

    options+=(-project "$xcodeproj_dir")

  else # --------------------- CocoaPods ---------------------
    if [ -n "$use_staging" ]; then
      source="https://github.com/objectbox/objectbox-swift-spec-staging.git"
    fi

    # Set version to minimum deployment target required by ObjectBox pod.
    # Note: all other projects are iOS and might not contain iOS in name.
    if [[ $project =~ "macOS" ]]; then
    echo "platform :osx, '10.15'
  " > Podfile
    else
    echo "platform :ios, '12.0'
  " > Podfile
    fi

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

fi
