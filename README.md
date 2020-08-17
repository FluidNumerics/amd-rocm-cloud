# ROCm Cloud - Imaging and Infrastructure as Code
Copyright 2020 Fluid Numerics LLC

This repository contains scripts for creating VM images with the [ROCm platform](https://rocmdocs.amd.com/en/latest/) on Google Cloud and Microsoft Azure.
The build scripts provided under `scripts/` are used to install AMD's `rocm-dev` (+ [`hipfort`](https://github.com/https://github.com/ROCmSoftwarePlatform/hipfort)) and Nvidia's CUDA Toolkit. The resulting image provides a development environment for creating portable GPU accelerated HPC applications that can run on both AMD and Nvidia GPUs.

Use of the resulting image requires you agree to the terms and condition in the [CUDA-Toolkit EULA](https://docs.nvidia.com/cuda/eula/index.html)

## Getting Started
1. [Download and install Packer](https://www.packer.io/downloads)

## Create a VM image for Azure

The instructions in this section are based on the Azure documentation ["How to use Packer to create Linux virtual machine images in Azure"](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer).

1. Navigate to the azure subdirectory 
```
cd azure/
```
2. Create a resource group. In this example, the resource group is named "rocm". The name you choose here will be passed to the "resource_group" variable in Step 5. 
```
az group create -n rocm -l westus
```
3. Create service principal credentials. The output of this command will provide you with the `client_id`, `client_secret`, and `tenant_id` needed when running packer in Step 5.
```
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"`.
```
4. Obtain your subscription id. This will provide the `subscription_id` needed when running packer in Step 5. 
```
az account show --query "{ subscription_id: id }"
```
5. Run packer using the appropriate variable substitutions. The resulting image name will be called "rocm-cloud".
```
packer build -force -var client_id="CLIENT ID" \
                    -var client_secret="CLIENT SECRET"\
                    -var tenant_id="TENANT ID"\
                    -var subscription_id="SUBSCRIPTION ID"\
                    -var resource_group="RESOURCE GROUP"\
                    ./packer.json
```

This build process installs ROCm 3.5.1 and the latest version of hipfort under `/opt/rocm-3.5.0`. The `PATH` environment is configured to include `/opt/rocm-3.5.0/bin:/opt/rocm-3.5.0/hipfort/bin`

### Testing you VM Image on Azure
You can create an instance with a AMD Radeon Instinct MI25 GPU attached using the following command :
```
az vm create \
    --resource-group "RESOURCE GROUP" \
    --name "rocm-vm" \
    --image "rocm-cloud" \
    --admin-username azureuser \
    --size "Standard_NV32as_v4" \
    --generate-ssh-keys
```

Once you SSH into the instance, you can run `rocminfo` to verify that the packages have been installed and that a GPU is detected.

## Create a VM image for Google Cloud
These instructions will show you how to build a Google Compute Engine (GCE) image that has ROCm 3.5.1 and hipfort installed.

### Prerequisites
Complete the steps in "Getting Started" shown above. Then, [follow these instructions to set up a service account and obtain service account credentials (JSON)](https://www.packer.io/docs/builders/googlecompute.html#running-without-a-compute-engine-service-account). You will need to provide the service account `Compute Instance Admin (v1)` and `Service Account User` IAM roles on the Google Cloud project you will build the image on. This allows the service account to create GCE instances and save disk images on Google Cloud.

1. Navigate to the azure subdirectory 
```
cd google/
```
2. Run packer using the appropriate variable substitutions. The resulting image name will be called `rocm-cloud-SOURCE_IMAGE`, where `SOURCE_IMAGE` is the name of the image you used as a starting point for your build. At a minimum, you must provide the `project_id`. [Default parameters](./google/packer.json) will create an image based on Ubuntu 20.04.
```
packer build -force -var project_id="PROJECT ID" \
                    -var subnet="SUBNETWORK"\
                    -var zone="ZONE"\
                    -var source_image="SOURCE IMAGE"\
                    -var source_image_project_id="SOURCE IMAGE PROJECT ID"\
                    -var startup_script="STARTUP SCRIPT"\
                    ./packer.json
```
The `startup_script` can be one of `scripts/centos/startup-script.sh` for CentOS-7 source image operating systems or `scripts/ubuntu/startup-script.sh` for Ubuntu operating systems.

This build process installs ROCm 3.5.1 and the latest version of hipfort under `/opt/rocm-3.5.0`. The `PATH` environment is configured to include `/opt/rocm-3.5.0/bin:/opt/rocm-3.5.0/hipfort/bin`



### Easy HPC Cluster Image
If you want to leverage ROCm on an elastic, cloud-native HPC cluster, you can use [Fluid Numerics' fluid-slurm-gcp](https://console.cloud.google.com/marketplace/details/fluid-cluster-ops/fluid-slurm-gcp) CentOS-7 or Ubuntu compute images as the `source_image` to start from.


**CentOS :** To create an image that you can use with the [CentOS solution](https://console.cloud.google.com/marketplace/details/fluid-cluster-ops/fluid-slurm-gcp), set `source_image="fluid-slurm-gcp-compute-centos-v2-4-0" and `source_image_project_id="fluid-cluster-ops"`.

**Ubuntu :** To create an image that you can use with the [Ubuntu solution](https://console.cloud.google.com/marketplace/details/fluid-cluster-ops/fluid-slurm-gcp-ubuntu), set `source_image="fluid-slurm-gcp-compute-ubuntu-v2-4-0" and `source_image_project_id="fluid-cluster-ops"`.


Once the image is created, you can [modify your cluster-config](https://github.com/FluidNumerics/fluid-slurm-gcp_custom-image-bakery#substituting-custom-images-in-your-compute-partitions) so that a compute partition uses your new custom image. Reach out to fluid-slurm-gcp@fluidnumerics.com at any time for assistance in getting started with ROCm on Fluid-Slurm-GCP.

This image will allow you to easily use ROCm the elastic click-to-deploy [Fluid-Slurm-GCP HPC Cluster](https://console.cloud.google.com/marketplace/details/fluid-cluster-ops/fluid-slurm-gcp) on Google Cloud.
