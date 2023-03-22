#!/bin/bash -xe

# kubeadm: the command to bootstrap the cluster. kubeadm will not install or manage kubelet or kubectl for you
# kubelet: the component that runs on all of the machines in your cluster and does things like starting pods and containers.
# kubectl: the command line util to talk to your cluster.

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# In releases older than Debian 12 and Ubuntu 22.04, /etc/apt/keyrings does not exist by default. You can create this directory if you need to, making it world-readable but writeable only by admins.
sudo mkdir -m 0755 -p /etc/apt/keyrings

sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl