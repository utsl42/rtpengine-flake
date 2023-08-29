# Nix flake to build and configure [RTPEngine](https://github.com/sipwise/rtpengine)

Builds RTPEngine, and provides a simple Nix module to configure and start the 
service. Kernel module builds, might work. The `iptables` module is completely untested,
not sure how to hook it into the path for `iptables` to find it.

See the container configuration defined in the flake for an example.

