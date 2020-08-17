#!/bin/bash


# Install GNU compilers and CMake
apt -y update
apt-get install -y libnuma-dev \
                   build-essential \
                   gfortran \
                   cmake \
                   tcsh \
                   make \
                   gcc \
                   gfortran \
                   flex \
                   bison \
                   patch \
                   bc \
                   xorg-dev \
                   libbz2-dev \
                   wget \
		   git \
		   software-properties-common

# Install CUDA toolkit
apt-get install -y nvidia-cuda-toolkit

# Install ROCm
wget -q -O - http://repo.radeon.com/rocm/apt/debian/rocm.gpg.key | sudo apt-key add -
echo 'deb [arch=amd64] http://repo.radeon.com/rocm/apt/3.5.1/ xenial main' | sudo tee /etc/apt/sources.list.d/rocm.list

apt -y update
apt install -y rocm-dev3.5.0

echo 'ADD_EXTRA_GROUPS=1' | sudo tee -a /etc/adduser.conf
echo 'EXTRA_GROUPS=video' | sudo tee -a /etc/adduser.conf

# Install hipfort
git clone https://github.com/ROCmSoftwarePlatform/hipfort.git /tmp/hipfort
cd /tmp/hipfort && \
mkdir build && 
cd build && \
cmake -D CMAKE_INSTALL_PREFIX=/opt/rocm-3.5.1/hipfort ../ && \
make && make install 
