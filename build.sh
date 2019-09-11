#!/usr/bin/env bash
set -eu

project=$1

options=CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO"

cd ${project}
xcodebuild clean build ${options} -project ${project}.xcodeproj -scheme ${project} 
