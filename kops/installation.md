# Installation

```
brew update && brew upgrade
brew install kops
```

[Guide](https://kops.sigs.k8s.io/getting_started/aws/)

## Setup AWS IAM

- User: tankhuu (Admin Access)

## Variables

```
# Global Variables
bucket="lu3k-kops-state"
export NAME="lu3k.link"
export KOPS_STATE_STORE="s3://$bucket"
```

## Domain

- lu3k.link

```
# Check DNS 
dig ns lu3k.link
```

## Cluster State Storage

```
region="us-east-1"
aws s3api create-bucket \
  --bucket $bucket \
  --region $region
aws s3api put-bucket-versioning --bucket $bucket --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket $bucket --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
```

## Create Cluster

```
region="ap-southeast-2"
# Get the first AZ of a region (for sample cluster), in production build, should use all AZs
az=$(aws ec2 describe-availability-zones --region $region --output text --query 'AvailabilityZones[*].ZoneName' | awk -F ' ' '{print $1}')

# kops create -f <cluster spec> will register a cluster using a kOps spec yaml file
kops create cluster --zones=$az ${NAME}
kops update cluster --name $NAME --yes --admin

kops validate cluster --wait 10m

# Get cluster template
kops get $NAME -o yaml > kops/$NAME.yaml

cat ~/.kube/config
kubectl get nodes
```

## Get kubectl config from storage state

```
export KOPS_STATE_STORE=<location of the kops state store>
NAME=<kubernetes.mydomain.com>
kops export kubeconfig ${NAME} --admin
```

## Update Cluster by template

```
# Update content of $NAME.yaml
kops replace -f $NAME.yaml
kops update cluster $NAME # updates a kubernetes cluster to match the cloud and kOps specifications. [Review mode]
kops rolling-update cluster --name $NAME --yes # apply changes
```

## Update SSH key to access instances

[Guide](https://github.com/kubernetes/kops/blob/master/docs/security.md)

## Delete Cluster

```
kops delete cluster --name ${NAME} --yes
```
