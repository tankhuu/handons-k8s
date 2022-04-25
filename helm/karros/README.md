# devops-helm-charts

Helm Charts for DevOps to package Edulog &amp; Karros Projects

## Prerequisites

- Helm v3 [Installing Helm](https://helm.sh/docs/intro/install/)
- Python v3 [Installing Python3](https://www.python.org/downloads/)

## [Optional] Follow this guide to create a Private Helm Chart Repository in AWS S3

[CreateS3Repository](s3Repo/README.md)

## Update dependencies for Athena Helm Chart

```
helm dep up athena
```

## Package a chart and Push to Repository

```
helm package <ChartName>
helm s3 push <ChartName>-<ChartVersion>.tgz <ChartsRepo>
# Search for charts in Repo
helm search repo <ChartsRepo>
```

## Install Athena Backend Services for a Site

Follow this guideline:

[Install athena backend services](athena/README.md)

## Upgrade Athena Backend Services for a Site

Follow this guideline:

[Upgrade athena backend services](athena/README.md)

## Errors & Fixes

[Errors & Fixes Guidelines](errors-fixes/README.md)
