# Kubernetes Overview

CafeDa - Tan Khuu

## Slides 

## Demo

```
# Bring up Marine Instance
cd ansible
ansible-playbook deploy.yml

# Access Marine
ssh -i ~/.ssh/marine.pem ec2-user@<PUBLIC-IP>

# -----
aws configure # setup aws cli with tankhuu account
# -----

# Bring up K8s Cluster
## Env Vars for kops clusters
DOMAIN="lu3k.link"
BUCKET="lu3k-kops-state"
export NAME="$DOMAIN"
export KOPS_STATE_STORE="s3://$BUCKET"

## Create Cluster
kops create -f kops/clusters/basic/$NAME.yaml
kops update cluster --name $NAME --yes --admin


# Demo Scenarios

# Cleanup 
# kops delete cluster $NAME --yes
```