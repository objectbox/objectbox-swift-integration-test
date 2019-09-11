#!/usr/bin/env bash
set -eu

project=$1

cd ${project}
xcodebuild clean build -project ${project}.xcodeproj -scheme ${project}
