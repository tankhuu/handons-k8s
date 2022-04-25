# Guideline to setup Private Helm Charts Repository

## Create S3 Bucket

S3_BUCKET: `athena-pre-helm-charts`

S3_PATH: `s3://${S3_BUCKET}/stable/athena`

```
# Create an S3 bucket for Helm charts.
REPO_NAME="stable-athena"
S3_BUCKET="athena-pre-helm-charts"
S3_PATH="s3://${S3_BUCKET}/stable/athena"

# Install the helm-s3 plugin for Amazon S3.
helm plugin install https://github.com/hypnoglow/helm-s3.git

# Initialize the Amazon S3 Helm repository.
helm s3 init $S3_PATH

# Verify the newly created Helm repository.

# Add the Amazon S3 repository to Helm on the client machine
helm repo add $REPO_NAME $S3_PATH

# Package chart
cd /Users/tankhuu/GitHub/Karros/devops-helm-charts/
helm package geocodeservice

# Push to Helm Repository
helm s3 push geocodeservice-0.1.0.tgz $REPO_NAME

# Search for new service
helm search repo $REPO_NAME

# Add dependencies
helm dep up athena
```
