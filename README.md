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

## Note on DNS
I wanted a way that I could navigate to my apps via nice, neat URLs like `homepage.sloan.com` or `grafana.sloan.com`. This meant that I needed to set up some sort of DNS server locally -- separate from the Kubernetes cluster.

To achieve this, I set up [pihole](https://docs.pi-hole.net/) on a pi that is NOT a worker node on this cluster and made it the first DNS server on my Unifi router. This pi, however, is also currently running my [Home Library](https://github.com/seamus-sloan/home-library) application. This means that to access the pihole, I needed to use port 8081 (rather than 8080) for the pihole webpage.

Once navigated to `http://192.168.1.101:8081/admin`, I can now see all of the pihole settings and create the appropriate A records within `https://192.168.1.101:8081/admin/settings/dnsrecords` (the left panel).

Since k8s uses the controlplane as the entry point for all applications, I only need to add the specified domain as a DNS record (i.e. `homepage.sloan.com | 192.168.1.99`) and then adjust the `ingress.yaml` for the application (i.e. `- host: homepage.sloan.com`). 
