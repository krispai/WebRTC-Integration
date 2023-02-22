# Introduction

This document will contain reference on how to integrate Krisp with WebRTC. 
The updated are pending. Stay tuned. 

# Build WebRTC 

Make sure to have access to the following repository 
https://github.com/krispai/webrtc 

The repository the Git Fork of Google WebRTC that has modifications required to integrate Krisp. 

Download Google depot_tools and install it your machine.
export DEPOTTOOLS=your installation

copy depot_tools/fetch_configs/krisp-webrtc.py to $DEPOTTOOLS/fetch_configs 

copy depot_tools/fetch_configs/krisp-webrtc_ios.pyy to $DEPOTTOOLS/fetch_configs 

export PATH:$DEPOTTOOS:$PATH 

cd yourworkdir 
fetch --nohooks krisp-webrtc_ios 
git checkout YOURBRANCH 
gclient sync 
