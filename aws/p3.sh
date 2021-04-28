#!/bin/bash
# Install Singularity
sudo apt-get update 
sudo apt-get install -y     build-essential libssl-dev     uuid-dev     libgpgme11-dev     squashfs-tools libseccomp-dev     pkg-config
sudo wget https://golang.org/dl/go1.16.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.16.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
sudo -E /usr/local/go/bin/go get -d github.com/sylabs/singularity
sudo -E git clone https://github.com/sylabs/singularity.git
cd singularity
sudo -E git checkout v3.7.3
## sudo -E ./mconfig
## cd builddir/
## sudo -E make
## sudo -E make install
