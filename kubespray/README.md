# Launch k8s Cluster in AWS using kubespray

## Prerequisites

- git
- ansible > 2.9
- [kubepray](https://github.com/kubernetes-sigs/kubespray)

## Setup AWS Infra

```
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
pip3 install -r requirements.txt
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
ssh -i $key admin@$bastionHost 'sudo mkdir -p /etc/ansible/ && sudo chown admin:admin /etc/ansible/'
ssh -i $key admin@$bastionHost

# In bastion host
sudo apt update
sudo apt upgrade -y
sudo apt install git ansible -y
exit

scp -i $key inventory/hosts admin@$bastionHost:/etc/ansible/hosts
ssh -i $key admin@$bastionHost

git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
ansible-playbook ./cluster.yml -e ansible_user=admin -b --become-user=root --flush-cache --extra-vars="ansible_ssh_private_key_file=/home/admin/.ssh/k8s.pem"
# Creation time: 

# => Should sync config to S3 with KMS encrypted

```

## ssh-bastion.conf

```


Host 13.211.47.138
  Hostname 13.211.47.138
  StrictHostKeyChecking no
  ControlMaster auto
  ControlPath ~/.ssh/ansible-%r@%h:%p
  ControlPersist 5m

Host  10.9.202.29 10.9.213.223 10.9.195.10 10.9.201.143 10.9.210.43 10.9.200.253 10.9.219.68
#IdentityFile /Users/tankhuu/.ssh/k8s.pem
  ProxyCommand ssh -F /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -p 22 admin@13.211.47.138 -i /Users/tankhuu/.ssh/k8s.pem
```

## Control Cluster from Bastion Host

```
mkdir -p $HOME/.kube
sudo cp -l /etc/kubernetes/admin.conf $HOME/.kube/config
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