# Home Lab

>[!NOTE] I'm just trying to learn to home lab and k8s at the same time.

## Hardware
- Control-Plane: `stormfather` (Ubuntu 24.04, intel i3-7100, 8GB, amd64)
- Workers:
  - `kvothe` (Raspberry Pi 5 8GB, arm64)
  - `sylphrena` (Raspberry Pi 5 8GB, arm64)

## Worker Installation
See `/scripts/setup-pi-worker.sh` for details on how new nodes can be added to the cluster.