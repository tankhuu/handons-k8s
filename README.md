# handons-k8s

Handons K8s

## Create Cluster

```
AWS_PROFILE=lab eksctl create cluster -f eks/cluster.yaml
```

## Delete Cluster

```
AWS_PROFILE=lab eksctl delete cluster -f eks/cluster.yaml
```
