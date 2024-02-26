***Instruction Building WebRTC Audio Hook for IOS***

mkdir workdir
cd workdir
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=`pwd`/depot_tools:$PATH
fetch --nohooks webrtc_ios
cd src
git checkout -b 6167-modified 6713461a2fb331c43d42b781fbe29da3f5d504a6
git apply audio-hook-webrtc-121.patch
cd ..
gclient sync
cd ./tools_webrtc/ios
python3 build_ios_libs.py
cd ../..
ls -l out_ios_libs/WebRTC.xcframework
