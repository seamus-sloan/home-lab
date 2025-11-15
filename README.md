# Home Lab

> [!NOTE]
> I'm just trying to learn to home lab and k8s at the same time.

## Hardware
- Control-Plane: `stormfather` (Ubuntu 24.04, intel i3-7100, 8GB, amd64)
- Workers:
  - `kvothe` (Raspberry Pi 5 8GB, arm64)
  - `sylphrena` (Raspberry Pi 5 8GB, arm64)
  - `szeth` (Raspberry Pi 5 8GB, arm64)

## Worker Installation
See `/scripts/setup-pi-worker.sh` for details on how new nodes can be added to the cluster.

## Note on SSH into Pi
Raspberry Pi OS (Lite) does not come instantly equipped with SSH functionality. To activate it, you'll have to mount the boot drive on your main computer then:
```sh
# Navigate to the correct directory
cd /Volumes/bootfs/

# Create an ssh file
touch ssh

# Create the ssh password (keep this for the userconf.txt file later...)
openssl passwd -6

# Add a userconf.txt file
nano userconf.txt

# Insert the credentials into the userconf.txt file
# The file contents should look something like
#     my-username:$54321.$abcd.zyx:987

# Eject the media & insert into a pi
cd ~ && diskutil eject /Volumes/bootfs
```
