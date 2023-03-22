#!/bin/bash -xe

echo "$(hostname -i) k8scp" | sudo tee -a /etc/hosts

cat << EOF > kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: 1.26.3
controlPlaneEndpoint: "k8scp:6443"
networking:
  podSubnet: 192.168.0.0/16
EOF

sudo systemctl stop containerd
sudo kubeadm init --config=kubeadm-config.yaml --upload-certs | tee kubeadm-init.out

# Network Plugin is used for pod's network communication inside of cluster
## Calico is good option
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml

watch kubectl get pods -n calico-system

sudo kubeadm config print init-defaults