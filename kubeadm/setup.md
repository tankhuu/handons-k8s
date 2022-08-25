# Setup K8s Cluster with KubeAdm

- [Guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

## EC2 Instances

- OS: Ubuntu 22.04 LTS
- Control Plane: 1
  - Type: t3a.small
  - CPU: 2
  - Memory: 4GB
  - Disk: 20GB
- Worker Nodes: 3
  - Type: t3a.small
  - CPU: 2
  - Memory: 4GB
  - Disk: 20GB

## Setup Control Plane

- Security Group:
  - SSH
  - HTTPS
  - TCP: 6443

```
ssh control
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker Engine
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker ${USER}

exit
ssh control
groups
docker ps

# Install cri-dockerd
## Check Instance Architecture
dpkg --print-architecture
## Download latest version: https://github.com/Mirantis/cri-dockerd/releases
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.1/cri-dockerd_0.2.1.3-0.ubuntu-jammy_amd64.deb
sudo dpkg -i cri-dockerd_0.2.1.3-0.ubuntu-jammy_amd64.deb
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket

# Install kubeadm
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Init
sudo su -
kubeadm config images pull
kubeadm init --cri-socket unix:///var/run/cri-dockerd.sock
# missing optional cgroups: blkio

# Install Pod Network
# Using Weave
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

> Note

```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.31.30.100:6443 --token poeuf9.54623ltowmd9gsws \
	--discovery-token-ca-cert-hash sha256:39031847bea980af812366001f4b283269a5cb31e567d4a8abd8da21d38c09ee
```

## Setup Worker Nodes


- Security Group:
  - SSH
  - HTTPS

```
ssh worker1
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker Engine
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker ${USER}

exit
ssh worker1
groups
docker ps

# Install cri-dockerd
## Check Instance Architecture
dpkg --print-architecture
## Download latest version: https://github.com/Mirantis/cri-dockerd/releases
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.1/cri-dockerd_0.2.1.3-0.ubuntu-jammy_amd64.deb
sudo dpkg -i cri-dockerd_0.2.1.3-0.ubuntu-jammy_amd64.deb
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket

# Install kubeadm
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Join Cluster
sudo su -
kubeadm join 172.31.30.100:6443 --token poeuf9.54623ltowmd9gsws \
	--discovery-token-ca-cert-hash sha256:39031847bea980af812366001f4b283269a5cb31e567d4a8abd8da21d38c09ee \
  --cri-socket unix:///var/run/cri-dockerd.sock
```