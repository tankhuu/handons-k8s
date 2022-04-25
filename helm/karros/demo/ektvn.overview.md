# Helm Charts Demo - Overview

## KarrosCloud Resources

- CreateTenant: http://cicd.athena-nonprod.com/job/devops/job/karros-cloud/job/create-tenant/
- SetTenantDefaultSettings: http://cicd.athena-nonprod.com/job/devops/job/karros-cloud/job/set-tenant-default-settings/
- CreateMCUser: http://cicd.athena-nonprod.com/job/devops/job/karros-cloud/job/create-user/

## AWS Resources

Git: https://github.com/eduloginc/devops-iac/tree/master/athena/cfn/templates

```
ENV_TYPE="nonprod"
SITE_NAME="ektvn"
PROJECT="athena"
STACK_NAME="${PROJECT}-${SITE_NAME}"
TENANT_ID="d582ea4d-59fb-4374-aa51-4127cc0996d7"

REGION=us-east-2
S3_DEVOPS="edulog-athena-devops"
S3_DEVOPS_PREFIX="iac/cloudformation/athena/${ENV_TYPE}/${SITE_NAME}"
OUTPUT_MASTER_TEMPLATE="${PROJECT}.${SITE_NAME}.yaml"
MASTER_TEMPLATE="athena/cfn/templates/main.yml"

AUTHOR=devops
CREATOR="tan.khuu@karrostech.com"
INFRAS_VERSION=v2

VPC_STACK_NAME="athena-nonprod-vpc"
KEYPAIR="athena-devops"
DOMAIN="athena-nonprod.com"
HOSTEDZONE_ID="Z0554033189HKTXE7UEFR"
SSL_CERTIFICATE_ARN="arn:aws:acm:us-east-1:696952606624:certificate/6ce0fe36-9363-4eee-b3ab-253895739d4b"
DB_INSTANCE_TYPE="db.t3.medium"
DB_ALLOCATED_STORAGE="50"
DB_MAXALLOCATED_STORAGE="70"
DB_MASTER_PASSWORD="rU18iWV4qxKU"
DB_SNAPSHOT_ID="arn:aws:rds:us-east-2:696952606624:snapshot:athena-ktvn-rds-helm-demo-20210614"


aws --region ${REGION} cloudformation package --template-file ${MASTER_TEMPLATE} --force-upload \
  --s3-bucket ${S3_DEVOPS} --s3-prefix ${S3_DEVOPS_PREFIX} --output-template-file ${OUTPUT_MASTER_TEMPLATE}

aws s3 cp ${OUTPUT_MASTER_TEMPLATE} s3://${S3_DEVOPS}/${S3_DEVOPS_PREFIX}/${OUTPUT_MASTER_TEMPLATE}

aws --region ${REGION} cloudformation deploy --template-file ${OUTPUT_MASTER_TEMPLATE} \
  --s3-bucket ${S3_DEVOPS} --s3-prefix ${S3_DEVOPS_PREFIX} \
  --stack-name ${STACK_NAME} \
  --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
  --force-upload \
  --tags \
    environment=${ENV_TYPE} \
    project=${PROJECT} \
    author=${AUTHOR} \
    siteName=${SITE_NAME} \
    creator=${CREATOR} \
    infras=${INFRAS_VERSION} \
  --parameter-overrides \
    Tenant=${SITE_NAME} \
    TenantId=${TENANT_ID} \
    Env=${ENV_TYPE} \
    VPCStackName=${VPC_STACK_NAME} \
    KeyPairName=${KEYPAIR} \
    FEDomain=${DOMAIN}  \
    FEHostedZoneId=${HOSTEDZONE_ID} \
    FESSLCertificateId=${SSL_CERTIFICATE_ARN} \
    DBInstanceClass=${DB_INSTANCE_TYPE}  \
    DBAllocatedStorage=${DB_ALLOCATED_STORAGE}  \
    DBMaxAllocatedStorage=${DB_MAXALLOCATED_STORAGE}  \
    DBMasterUserPassword=${DB_MASTER_PASSWORD} \
    DBSnapshotIdentifier=${DB_SNAPSHOT_ID}

```

## Deploy Frontend

Artifact: s3://edulog-athena-artifacts/frontend/build/a761b93b95734e0d9fbc844806d2a42f8debed8e.tar.gz

```
S3_ARTIFACTS="edulog-athena-artifacts"
S3_ARTIFACTS_PREFIX="frontend/build"
FE_RELEASE_VERSION="a761b93b95734e0d9fbc844806d2a42f8debed8e"

aws s3 cp s3://${S3_ARTIFACTS}/${S3_ARTIFACTS_PREFIX}/${FE_RELEASE_VERSION}.tar.gz .
tar zxvf ${FE_RELEASE_VERSION}.tar.gz
cd $FE_RELEASE_VERSION
# Update systemconfig.json
vi asset/systemconfig.json

# Deploy
aws s3 cp --acl public-read --recursive . s3://${domain}/
aws s3 cp --acl public-read --cache-control max-age=0 ./index.html s3://${domain}/
aws s3 cp --acl public-read --cache-control max-age=0 ./ngsw-worker.js s3://${domain}/
```

```
# Simplier way is to clone from ktvn
aws s3 cp --acl public-read --recursive s3://ktvn.athena-nonprod.com/ s3://ektvn.athena-nonprod.com/
```

## EKS Resources

Git:

namespace: ektvn

core:

- gateway
- tnxhub
- routing
- geocode
- import
- mongodb
- rabbitmq

MapOverlay:

- overlay
- geoserver

RideRegistration:

- aggregate
- rres

Values: `ektvn.values.yaml`

### Package & Deploy

```
site="ektvn"
chartName="athena"
repo="stable-athena"

# update dependencies
helm dep up $chartName

# Package & Push Chart
helm lint $chartName
helm package $chartName
helm s3 push --force $chartName-*.tgz $repo

# Deploy Charts

## Create namespace
kubectl create namespace $site

## deploy cache & queue
helm -n $site install --wait -f "${site}-cache.values.yaml" mongodb bitnami/mongodb

helm -n $site install --wait -f "${site}-queue.values.yaml" rabbitmq bitnami/rabbitmq

## Deploy Backend Services
helm -n $site install --wait -f "$site.values.yaml" $site $chartName --create-namespace

## Check swagger
https://ath-be-ektvn.athena-nonprod.com/swagger-ui.html

## Get status
helm -n $site status $site

```

### Upgrade Release

Upgrading for Athena Backend Services

```
helm -n $site upgrade --reuse-values --wait $site $chartName -f $site.<version>.values.yaml
```

Upgrading for MongoDb & RabbitMQ will need more parameter on password, so we can't deploy them as a subchart of Athena project

```
# export RABBITMQ_ERLANG_COOKIE=$(kubectl get secret --namespace "$site" $site-rabbitmq -o jsonpath="{.data.rabbitmq-erlang-cookie}" | base64 --decode)

# helm -n $site upgrade -f "$site.values.yaml" $site $chartName
```

### Cleanup

```
kubectl delete namespaces $site

# helm -n $site uninstall $site
# helm -n $site uninstall mongodb
# helm -n $site uninstall rabbitmq
```

### Get Release History

For getting Release Revision

```
helm -n $site history $site
```

### Get values of a revision

```
helm -n $site get values $site --revision <REVISION>
```

### Rollback

```
helm -n $site rollback $site <REVISION>
```

### Get MongoDB info

```
kubectl get secret --namespace "ektvn" ektvn-mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 --decode

export MONGODB_ROOT_USER=admin
export MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace $site mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)
```

### Connect MongoDB

kubectl port-forward --namespace ektvn svc/mongodb 27017:27017 &
mongo --host 127.0.0.1 --authenticationDatabase admin -p $MONGODB_ROOT_PASSWORD

### Get RabbitMQ Info

```
export QUEUE_USER=user
export QUEUE_PASSWORD=$(kubectl get secret --namespace ektvn rabbitmq -o jsonpath="{.data.rabbitmq-password}" | base64 --decode)
export QUEUE_ERLANG_COOKIE=$(kubectl get secret --namespace ektvn rabbitmq -o jsonpath="{.data.rabbitmq-erlang-cookie}" | base64 --decode)
```

### DB Snapshot

s3://edulog-athena-backup/athena/database/nonprod/ktvn/Athena-ktvn.20210616-101951.bak
