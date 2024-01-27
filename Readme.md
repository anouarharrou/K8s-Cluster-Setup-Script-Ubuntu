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
wget https://raw.githubusercontent.com/anouarharrou/K8s-Cluster-Setup-Script-Ubuntu/main/install-k8s.sh
```

### Step 2: Make the Script Executable

Grant execute permissions to the script.

```bash
chmod +x install-k8s.sh
```
### Step 3: Run the Script

Execute the script with root or sudo privileges.

```bash
sudo ./install-k8s.sh
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
👋 I'm a State Engineer in Information Technology and Communication Networks, currently serving as a DevOps Engineer at Société Générale Africa Business Services (SGABS). I'm passionate about automating and streamlining deployment processes for infrastructure and applications, and I'm excited to share my journey and ongoing projects with you.

🌱 Currently, I'm deeply engaged in a comprehensive pipeline project designed to automate and facilitate the deployment of both infrastructure and applications. Leveraging a combination of Ansible, Jenkins, and Terraform, our team is crafting a robust system to streamline and expedite the deployment processes within our company. This initiative aims to enhance efficiency and scalability while reducing manual intervention in the deployment lifecycle.

Previously, one of my significant endeavors involved crafting solutions to automate the creation and configuration of a Kubernetes cluster within the Promise environment. This project, set within an environment lacking an internet connection (For security measure, the environment can't get acces to the internet), posed unique challenges that I successfully navigated, further refining my skills in automation and orchestration.

I've also been actively involved in developing Ansible playbooks that automate the setup and configuration of diverse servers and packages within our infrastructure, harnessing the capabilities of the ManageIQ platform. This hands-on experience has bolstered my expertise in infrastructure automation and orchestration.

💡 I am continually driven by a thirst for learning and a passion for enhancing my expertise across various technological domains. Thriving in dynamic environments, I actively seek opportunities to contribute to innovative projects. If you have any collaboration ideas or opportunities aligned with my interests, I'm eager to explore and engage.


## 🔗 Links

[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/anouarharrou/)

## Contributing

Contributions are welcome! 
If you encounter issues or have suggestions for improvements, please open an issue or submit a pull request.
