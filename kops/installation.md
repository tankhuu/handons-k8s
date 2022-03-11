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
kops create cluster --zones=$az ${NAME}
kops update cluster --name $NAME --yes --admin
kops validate cluster --wait 10m

cat ~/.kube/config
kubectl get nodes
```

## Delete Cluster

```
kops delete cluster --name ${NAME} --yes
```
