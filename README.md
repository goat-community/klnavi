# KL.NAVI configuration and infrastructure

## Purpose

This repository contains configuration and the infrastructure for KL.NAVI project. It uses ArgoCD and Terraform to manage the infrastructure as code (IaC).

## Prerequisites

Before you can use this repository, you will need to install the following tools in your machine:

- [Terraform](https://www.terraform.io/)
- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/)

## Installation
The following deployment installation is specific to Hetzner Cloud provider

### Create Hetzner project and OpenSUSE MicroOS snapshot
1. Create a project in your [Hetzner Cloud Console](https://console.hetzner.cloud/), and go to **Security > API Tokens** of that project to grab the API key, it needs to be Read & Write. Take note of the key! ✅

2. Generate a passphrase-less ed25519 SSH key pair for your cluster; take note of the respective paths of your private and public keys. Or, see our detailed [SSH options](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner/blob/master/docs/ssh.md). ✅

3. Now navigate **packer** folder and create the MicroOS snapshot using the following commands.
```sh
packer build hcloud-microos-snapshots.pkr.hcl
packer init hcloud-microos-snapshots.pkr.hcl
```
## Dataset Sources
GTFS public transport data for this project is sourced from the following providers
- [VRN for bus, tram and local public transport](https://www.vrn.de/opendata/datasets)
- [GTFS.de for S-Bahn and regional rail](https://gtfs.de/en/feeds/de_rv)
