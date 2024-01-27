#!/bin/bash
# common.sh
# copy this script and run in all master and worker nodes
#) pre-requisites
#1) Ubuntu 20.04 LTS
#2) Internet connection
#3) Disable swap

# Function to check if a Kubernetes cluster already exists
check_k8s_cluster() {
    if kubectl cluster-info &> /dev/null; then
        echo "Error: Kubernetes cluster already exists. Exiting."
        exit 1
    fi
}

# Function to check if Docker or containerd.io is installed
check_docker_containerd() {
    if command -v docker &> /dev/null || command -v containerd &> /dev/null; then
        echo "Error: Docker or containerd.io is already installed. Skipping Docker installation."
        exit 1
    fi
}

# Verify if a Kubernetes cluster exists
check_k8s_cluster

#i1) Switch to root user [ sudo su], if you don't have root user access use sudo before each command.

#2) Disable swap & add kernel settings

swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

#optional: Set up hostnames -you can give unique hostnames for nodes so that Kubernetes can use these names to identify nodes
hostnamectl set-hostname "master-node"
exec bash

#Update the /etc/hosts File for Hostname Resolution
#Note: You can skip this step if you have DNS server in your environment.
vi /etc/hosts

#Add the following lines to the end of the file:
10.0.0.2 master-node  
10.0.0.3 worker-node1

#3) Add  kernel settings & Enable IP tables(CNI Prerequisites)

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

#4) Install containerd run time

#To install containerd, first install its dependencies.

apt-get update -y
apt-get install ca-certificates curl gnupg lsb-release -y

#Note: We are not installing Docker Here.Since containerd.io package is part of docker apt repositories hence we added docker repository & it's key to download and install containerd.
# Add Docker’s official GPG key:
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

#Use follwing command to set up the repository:

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# check if containerd runtime exists
check_docker_containerd

# Install containerd
apt-get update -y
apt-get install containerd.io -y

# Generate default configuration file for containerd

#Note: Containerd uses a configuration file located in /etc/containerd/config.toml for specifying daemon level options.
#The default configuration can be generated via below command.

containerd config default > /etc/containerd/config.toml

# Run following command to update configure cgroup as systemd for contianerd.

sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# Restart and enable containerd service

systemctl restart containerd
systemctl enable containerd

#5) Installing kubeadm, kubelet and kubectl

# Update the apt package index and install packages needed to use the Kubernetes apt repository:

apt-get update
apt-get install -y apt-transport-https ca-certificates curl

# Download the Google Cloud public signing key:

curl -fsSL https://dl.k8s.io/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

# Add the Kubernetes apt repository:

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:

apt-get update
apt-get install -y kubelet kubeadm kubectl

# apt-mark hold will prevent the package from being automatically upgraded or removed.

apt-mark hold kubelet kubeadm kubectl

# Enable and start kubelet service

systemctl daemon-reload
systemctl start kubelet
systemctl enable kubelet.service

#Initialize the Kubernetes cluster on the master node
kubeadm config images pull
kubeadm init --pod-network-cidr=10.10.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Deploy Calico network
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.10.0.0\/16/g' custom-resources.yaml
kubectl create -f custom-resources.yaml

#Add worker nodes to the cluster: this command is provided at the end of kubeadm init command output
kubeadm join &lt;MASTER_NODE_IP>:&lt;API_SERVER_PORT> --token &lt;TOKEN> --discovery-token-ca-cert-hash &lt;CERTIFICATE_HASH>

#Verify the cluster status
kubectl get nodes

#list all pods in all namespaces
kubectl get pods --all-namespaces

#confirm that all system pods are running
kubectl get pods --all-namespaces -o wide

#congratulations! you have successfully created a Kubernetes cluster with one master node and one worker node.
echo "congratulations! you have successfully created a Kubernetes cluster with one master node and one worker node."