#!/bin/bash

URL="https://github.com/krispai/webrtc/releases/download/v0.1-ios-ready/WebRTC.xcframework.v0.1-ios.zip"

CURRENT_DIR=$(pwd)
WETC_RTC_FRAMEWORK_PATH="$CURRENT_DIR/CustomFrameworks/webrtc"
WETC_RTC_FRAMEWORK_DIR="$WETC_RTC_FRAMEWORK_PATH/WebRTC.xcframework"
PODS_FRAMEWORK_DIR="$CURRENT_DIR/Pods/Starscream"

# validation of webrtc framework
if [ -d $WETC_RTC_FRAMEWORK_DIR ]; then
    echo "WebRTC.xcframework is already available"
else
    #download and unpack webrtc framework
    curl -L -o webrtc.zip "$URL"
    unzip webrtc.zip -d $WETC_RTC_FRAMEWORK_PATH
    rm webrtc.zip
fi

# validation of cocoapods
if which pod &> /dev/null; then
    if [ -d $PODS_FRAMEWORK_DIR ]; then
      echo "PODS frameworks are available"
    else
      # install pods
      pod install
    fi
else
    echo "CocoaPods is not installed, just use command: $sudo gem install cocoapods, to install it"
fi
