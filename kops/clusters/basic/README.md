# Create Basic Cluster

```
# Generate cluster template
sh create-template.sh

DOMAIN="lu3k.link"
BUCKET="lu3k-kops-state"
REGION="ap-southeast-2"
export NAME="$DOMAIN"
export KOPS_STATE_STORE="s3://$BUCKET"

# Update cluster template
kops create -f $NAME.yaml
kops update cluster --name $NAME --admin --yes
kops validate cluster --wait 10m
```