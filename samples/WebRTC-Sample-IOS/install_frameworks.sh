#!/bin/bash

# download and unpack webrtc framework
URL="https://github.com/krispai/webrtc/releases/download/v0.1-ios-ready/WebRTC.xcframework.v0.1-ios.zip"
CURRENT_DIR=$(pwd)
WETC_RTC_FRAMEWORK_PATH="$CURRENT_DIR/CustomFrameworks/webrtc"
curl -L -o webrtc.zip "$URL"
unzip webrtc.zip -d $WETC_RTC_FRAMEWORK_PATH
rm webrtc.zip

# install pods
pod install
