#!/usr/bin/env bash
set -eu

project=$1

cd ${project}
xcodebuild clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -project ${project}.xcodeproj -scheme ${project} 
