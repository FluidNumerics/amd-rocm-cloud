#!/bin/bash


# Install GNU compilers and CMake
yum -y update
yum -y install tcsh make \
               gcc gcc-gfortran gcc-c++ \
               which flex bison patch bc \
               libXt-devel libXext-devel \
               perl perl-ExtUtils-MakeMaker util-linux wget \
               bzip2 bzip2-devel zlib-devel tar git

yum install -y epel-release
yum install -y dkms kernel-headers-`uname -r` kernel-devel-`uname -r`

# Cmake install from source (version 3.12 or greater is needed for Amber20)
wget https://cmake.org/files/v3.12/cmake-3.12.3.tar.gz
tar -xvzf cmake-3.12.3.tar.gz
cd cmake-3.12.3
./bootstrap --prefix=/usr/local
make
make install
export PATH=${PATH}:/usr/local/bin


# Install CUDA Toolkit
yum install -y kernel-devel-$(uname -r) kernel-headers-$(uname -r)
yum install -y http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-10.0.130-1.x86_64.rpm
yum clean -y all
yum install -y cuda


# Install ROCm
cat <<EOT >> /etc/yum.repos.d/rocm.repo
[ROCm]
name=ROCm
baseurl=http://repo.radeon.com/rocm/yum/rpm
enabled=1
gpgcheck=0
EOT

yum install -y rocm-dev3.5.0

# Add any future users to the video group
echo 'ADD_EXTRA_GROUPS=1' | sudo tee -a /etc/adduser.conf
echo 'EXTRA_GROUPS=video' | sudo tee -a /etc/adduser.conf

# Install hipfort
git clone https://github.com/ROCmSoftwarePlatform/hipfort.git /tmp/hipfort
cd /tmp/hipfort && \
mkdir build && 
cd build && \
cmake -D CMAKE_INSTALL_PREFIX=/opt/rocm-3.5.0/hipfort ../ && \
make && make install 



