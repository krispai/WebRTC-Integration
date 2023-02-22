# DRAFT
# Introduction

This document will contain full reference on how to integrate Krisp with WebRTC.
The updated are pending. Stay tuned.

# Download prebuilt WebRTC Mod
TODO: make it available

# Build WebRTC Mod

Make sure to have access to the following repository
https://github.com/krispai/webrtc

This the Git Fork of Google WebRTC that has modifications required to integrate Krisp.

Download Google depot_tools and install it on your machine.
Let's consider that $DEPOT_TOOLS environement variable is set to the installation directory.

Please copy the following two configuration files to the depot_tools installation in the specified directory.
```
copy depot_tools/fetch_configs/krisp-webrtc.py to $DEPOT_TOOLS/fetch_configs
copy depot_tools/fetch_configs/krisp-webrtc_ios.py to $DEPOT_TOOLS/fetch_configs
```

Optionally we can add depot_tools to the PATH for the convinience
```
export PATH:$DEPOTTOOS:$PATH
```

Let's create a working directory somewhere
```
mkdir work_dir_somewhere
cd work_dir_somewhere
```

Now let's pull WebRTC Mod for IOS from WebRTC fork repository. The provided krisp-webrtc_ios.py configuration will be used to resolve the reference of the repository.
```
fetch --nohooks krisp-webrtc_ios
```

Optionally we can switch to another branch if needed
``` 
git checkout YOURBRANCH
```

The following step is required to finally configure the repository for the build.
```
gclient sync
```

Use build_ios_libs.py Python script to process the build.
TODO: add details
