#!/usr/bin/env bash
set -eu

project=$1

export CODE_SIGN_IDENTITY=""
export CODE_SIGNING_REQUIRED="NO"
export CODE_SIGN_ENTITLEMENTS=""
export CODE_SIGNING_ALLOWED="NO"

cd ${project}
xcodebuild clean build -project ${project}.xcodeproj -scheme ${project} 
