#!/bin/bash

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

# Disable swap & add kernel settings
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


# Add kernel settings & Enable IP tables(CNI Prerequisites)
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

# Install containerd runtime
apt-get update -y
apt-get install ca-certificates curl gnupg lsb-release -y

# Add Docker’s official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


# Install containerd
apt-get update -y
apt-get install containerd.io -y

# Generate default configuration file for containerd
containerd config default > /etc/containerd/config.toml

# Update configure cgroup as systemd for containerd
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# Restart and enable containerd service
systemctl restart containerd
systemctl enable containerd

# Install kubeadm, kubelet, and kubectl
apt-get update
apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://dl.k8s.io/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl

apt-mark hold kubelet kubeadm kubectl

systemctl daemon-reload
systemctl start kubelet
systemctl enable kubelet.service

# Initialize the Kubernetes cluster on the master node
kubeadm config images pull
kubeadm init --pod-network-cidr=10.10.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Deploy Calico network
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.10.0.0\/16/g' custom-resources.yaml
kubectl create -f custom-resources.yaml

echo "congratulations! you have successfully created a Kubernetes cluster with one master node and one worker node."
echo "You can now join any number of worker nodes by running the following on each as root:"