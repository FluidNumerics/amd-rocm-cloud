#!/bin/bash
# Set up ROCM part 1
sudo apt update
sudo apt -y dist-upgrade
sudo apt -y install libnuma-dev
sudo wget -q -O - https://repo.radeon.com/rocm/rocm.gpg.key | sudo apt-key add -
sudo echo 'deb [arch=amd64] https://repo.radeon.com/rocm/apt/debian/ xenial main' | sudo tee /etc/apt/sources.list.d/rocm.list
sudo apt update
sudo apt -y install rocm-dkms
sudo /sbin/shutdown -r now
