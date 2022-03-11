# Plan the Installation of new Cluster

## Setup Cluster with Spot Instances

[Guide](https://aws.amazon.com/getting-started/hands-on/run-kops-kubernetes-clusters-for-less-with-amazon-ec2-spot-instances/)

## Connect to existing kops Clusters project

- Need to have Cluster Storage State, which is hosted in S3
- Export it as environment variable: export KOPS_STATE_STORE=s3://<BucketName>

## Create a default cluster


## Generate Cluster template in yaml for easier to update


## Add cluster template to Git for easier maintaining & controlling


## Workthrough features