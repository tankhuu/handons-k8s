# Debezium Distributed Connectors Helm Chart

## Package & Upload to Repository

```
helm package debezium
helm s3 push debezium-*.gz <ChartName> <RepoName>
```

## Installation

helm install debezium --namespace <NameSpace> <ReleaseName> <ChartName>
