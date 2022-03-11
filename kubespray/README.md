# Launch k8s Cluster in AWS using kubespray

## Result

In 4 times setup, failed 3 times

## Prerequisites

- git
- ansible > 2.9
- [kubepray](https://github.com/kubernetes-sigs/kubespray)

## Setup AWS Infra

```
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
cd contrib/terraform/aws/
cp -p credentials.tfvars.example credentials.tfvars
# Update neccessary AWS Information for accessing

# Init Cluster Infra in AWS
clusterName="mondtest"
terraform init
terraform plan -var-file credentials.tfvars -out $clusterName.plan
terraform apply $clusterName.plan
# => Should setup state to S3
```

## Access

```
# => Should setup ansible role to setup cluster
key="/Users/tankhuu/.ssh/k8s.pem"
cd /Users/tankhuu/GitHub/practices/kubespray
bastionHost=$(cat inventory/hosts | grep "bastion ansible_host" | head -1 | awk -F '=' '{print $2}')
scp -i $key $key admin@$bastionHost:/home/admin/.ssh/
ssh -i $key admin@$bastionHost
echo "alias ll='ls -l'" >> /home/admin/.bash_profile

# In bastion host
sudo apt install gnupg2 -y
echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu bionic main" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
sudo apt update
sudo apt upgrade -y
sudo apt install python3-pip libffi-dev -y
sudo apt install git ansible -y
sudo apt install --no-install-recommends python-netaddr
exit

ssh -i $key admin@$bastionHost 'sudo mkdir -p /etc/ansible/ && sudo chown -R admin:admin /etc/ansible/'
scp -i $key inventory/hosts admin@$bastionHost:/etc/ansible/hosts
ssh -i $key admin@$bastionHost

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo mv kubectl /usr/local/bin/

# Create Cluster
runTime=$(date +%Y%m%d-%H%S)
git clone https://github.com/tankhuu/kubespray.git
cd kubespray
pip3 install -r requirements.txt
time ansible-playbook ./cluster.yml -e ansible_user=admin -b --become-user=root --flush-cache --extra-vars="ansible_ssh_private_key_file=/home/admin/.ssh/k8s.pem" > create-cluster.$runTime.log
# Creation time: start: 9:54 - end: 10:15 ~ 20 minutes
# real	19m38.497s
# user	13m23.046s
# sys	4m28.952s
# Copy creation log
scp -i $key admin@$bastionHost:/home/admin/kubespray/create-cluster.$runTime.log ~/GitHub/practices/k8s/kubespray
# => Should sync config to S3 with KMS encrypted

```

> Create cluster log

```
[WARNING]: Found both group and host with same name: bastion
[WARNING]: Skipping callback plugin 'ara_default', unable to load
[WARNING]: Could not match supplied host pattern, ignoring: kube-master
[WARNING]: Could not match supplied host pattern, ignoring: kube-node
[WARNING]: Could not match supplied host pattern, ignoring: k8s-cluster
[WARNING]: Could not match supplied host pattern, ignoring: calico-rr
[WARNING]: Could not match supplied host pattern, ignoring: no-floating
[WARNING]: Platform linux on host bastion is using the discovered Python interpreter at /usr/bin/python, but future installation of another Python interpreter could change this. See
https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information.
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: raw module does not support the environment keyword
[WARNING]: flush_handlers task does not support when conditional
[WARNING]: noop task does not support when conditional
```

## ssh-bastion.conf

```
# Copy from bastion
scp -i $key admin@$bastionHost:/home/admin/kubespray/ssh-bastion.conf ~/GitHub/practices/kubespray/

-------
Host 13.211.47.138
  Hostname 13.211.47.138
  StrictHostKeyChecking no
  ControlMaster auto
  ControlPath ~/.ssh/ansible-%r@%h:%p
  ControlPersist 5m

Host  10.9.202.29 10.9.213.223 10.9.195.10 10.9.201.143 10.9.210.43 10.9.200.253 10.9.219.68
#IdentityFile /Users/tankhuu/.ssh/k8s.pem
  ProxyCommand ssh -F /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -p 22 admin@13.211.47.138 -i /Users/tankhuu/.ssh/k8s.pem
-------
```

## Control Cluster from Bastion Host

```
controlNode=$(cat /etc/ansible/hosts | grep "kube_control_plane" -A 1 | head -n 2 | tail -n 1)
key="$HOME/.ssh/k8s.pem"
mkdir -p $HOME/.kube
scp -i $key admin@$controlNode:/etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get nodes
```


## Create DNS Record for API Server

```
# Create DNS record for Dashboard https://k8s-apiserver.lu3k.xyz:6443
apiserver_lb=$(cat inventory/hosts | grep "apiserver_loadbalancer_domain_name" | head -1 | awk -F '=' '{print $2}')
aws route53 change-resource-record-sets \
  --hosted-zone-id Z01981694XBS4VXYAWBJ \
  --change-batch '{"Comment":"Kubernetes Admin Dashboard","Changes":[{"Action":"CREATE","ResourceRecordSet":{"Name":"k8s-apiserver.lu3k.xyz","Type":"A","AliasTarget":{"HostedZoneId":"hosted zone ID for your CloudFront distribution, Amazon S3 bucket, Elastic Load Balancing load balancer, or Amazon Route 53 hosted zone","DNSName":"$apiserver_lb","EvaluateTargetHealth":false}}}]}'
```

## Enable Admin Dashboard

## Add Nodes



## Remove Nodes



## HPA


## 

## Destroy

```
cd /Users/tankhuu/GitHub/practices/kubespray/contrib/terraform/aws
terraform destroy -var-file credentials.tfvars -auto-approve
```

## References

- https://cloudolife.com/2021/08/28/Kubernetes-K8S/Kubespray/Use-Kubespray-to-deploy-a-Production-Ready-Kubernetes-Cluster/