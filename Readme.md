# Kubernetes Cluster Setup Script

## Introduction

This script automates the setup process for a Kubernetes cluster on Ubuntu 20.04 LTS, One Master and one Node. It covers the installation of necessary dependencies, kernel settings, and components such as containerd, kubeadm, kubelet, and kubectl.

## Prerequisites

    1. Ubuntu 20.04 LTS
    2. Internet connection
    3. Disable swap

## Usage


### Step 1: Download the Script

Download the `install.sh` script from this repository.

```bash
wget https://raw.githubusercontent.com/your-username/your-repo/master/install.sh
```

### Step 2: Make the Script Executable

Grant execute permissions to the script.

```bash
chmod +x install.sh
```
### Step 3: Run the Script

Execute the script with root or sudo privileges.

```bash
sudo ./install.sh
```

## Features

    Checks for existing Kubernetes clusters to prevent accidental reinstallation.
    Verifies the presence of Docker or containerd.io before installation.
    Automates the setup of hostnames, kernel settings, and CNI prerequisites.
    Installs and configures containerd runtime.
    Installs kubeadm, kubelet, and kubectl.
    Initializes the Kubernetes cluster on the master node.
    Deploys Calico network for pod networking.
    Provides instructions for adding worker nodes to the cluster.
    Verifies the cluster status and displays relevant information.



## Kubernetes Components 
Kubernetes Architecture

![Logo](https://kubernetes.io/images/docs/components-of-kubernetes.svg)


## Support

You will find some useful commands line on the folder :

```bash
./cmd/workingwithyourcluster.sh
./cmd/deployingapplications.sh
```


## 🚀 About Me
I'm a full stack developer...


## 🔗 Links

[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/anouarharrou/)

## Contributing

Contributions are welcome! 
If you encounter issues or have suggestions for improvements, please open an issue or submit a pull request.
