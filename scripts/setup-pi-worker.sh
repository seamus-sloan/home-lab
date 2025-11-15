#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f .env ]; then
  echo -e "${RED}Error: .env file not found${NC}"
  exit 1
fi

source .env

# Check if running as root, if not, re-run with sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}This script requires root privileges. Re-running with sudo...${NC}"
  sudo "$0" "$@"
  exit $?
fi


####################################
# Step 1: Confirm/Update Hostname #
####################################
CURRENT_HOSTNAME=$(hostname)
echo -e "${BLUE}Current hostname: ${GREEN}${CURRENT_HOSTNAME}${NC}"
echo -e "${YELLOW}This hostname will be used as the node's name in the cluster.${NC}"
read -p "Do you want to change the hostname? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -p "Enter new hostname: " NEW_HOSTNAME
  if [ -n "$NEW_HOSTNAME" ]; then
    echo -e "${BLUE}Setting hostname to ${GREEN}${NEW_HOSTNAME}${NC}"
    hostnamectl set-hostname "$NEW_HOSTNAME"
    echo -e "${GREEN}Hostname updated successfully!${NC}"
    CURRENT_HOSTNAME="$NEW_HOSTNAME"
  else
    echo -e "${RED}No hostname entered. Keeping current hostname.${NC}"
  fi
else
  echo -e "${GREEN}Keeping current hostname: ${CURRENT_HOSTNAME}${NC}"
fi
echo


########################
# Step 2: Disable swap #
########################
echo -e "${BLUE}Disabling swap...${NC}"
swapoff -a
sed -i 's/^\(.*swap\)/#\1/' /etc/fstab


#################################
# Step 3: Add cgroup parameters #
#################################
if ! grep -q "cgroup_memory=1" /boot/firmware/cmdline.txt || ! grep -q "cgroup_enable=memory" /boot/firmware/cmdline.txt; then
  echo -e "${BLUE}Adding cgroup parameters to /boot/firmware/cmdline.txt${NC}"
  echo "cgroup_memory=1 cgroup_enable=memory" >> /boot/firmware/cmdline.txt
  echo -e "${YELLOW}Reboot the pi and run this script again to continue installation.${NC}"
  exit $?
else
  echo -e "${GREEN}cgroup parameters already present in /boot/firmware/cmdline.txt${NC}"
fi


##############################
# Step 4: Install K3S Worker #
##############################
curl -sfL https://get.k3s.io | sh -s - \
  K3S_URL="${K3S_URL}" \
  K3S_TOKEN="${K3S_TOKEN}" \
  sudo sh -s - agent


##########################
# Step 5: Label the node #
##########################
kubectl label nodes ${CURRENT_HOSTNAME} node-role=worker


#############################
# Step 6: Verify K3S Worker #
#############################
echo -e "${GREEN}All done!${NC}"
echo -e "${YELLOW}Some helpful tips:${NC}"
echo -e "\t* Check the node status from the server with ${GREEN}kubectl get nodes -o wide${NC}"
echo -e "\t* Check the node labels with ${GREEN}kubectl get nodes -show-labels${NC}"
echo -e "\t* Check the logs with ${GREEN}sudo journalctl -u k3s-agent -n 50 --no-pager${NC}"
echo -e "\t* Make sure you can ping the server ${GREEN}ping ${K3S_URL}${NC}"
echo -e "\n\n\n"
echo -e "k3s agent status:"
systemctl status k3s-agent --no-pager