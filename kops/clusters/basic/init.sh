#!/bin/bash -xe

# [optional] Create AWS HostZone for every cluster 

DOMAIN="lu3k.link"
BUCKET="lu3k-kops-state"
REGION="ap-southeast-2"
AZs=$(aws ec2 describe-availability-zones --region $region --output text --query 'AvailabilityZones[*].ZoneName' | awk -F ' ' '{print $1}')

version="v1.23.4"
networking="calico"
topology="public"
masterType="m5.large"
masterCount=3
nodeType="m5.xlarge"
nodeCount=3

export NAME="basic-k8s.$DOMAIN"
export KOPS_STATE_STORE="s3://$BUCKET"
kops create cluster $NAME \
    --zones "$AZs" \
    --master-zones "$AZs" \
    --networking $networking \
    --topology $topology \
    --bastion \
    --master-size $masterType \
    --node-count $nodeCount \
    --node-size $nodeType \
    --kubernetes-version $version \
    --dry-run \
    -o yaml > $NAME.yaml