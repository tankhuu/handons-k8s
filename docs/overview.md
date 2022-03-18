# Overview K8s

## K8s Architecture

### Control Plane


### Worker Nodes



## All of K8s are about API

- RESTful
- API Group with version
- Access:
  - RBAC - Role-based access control
  - set of certificates associated to a name in ~/.kube/config

## K8s Clients

- kubectl
- k8s-dashboard
- curl

## Namespaces



## Pods

- IP Object
- Multiple containers
- K8s manage Pods, not containers

## Deployments

- Pod is apart of deployment
- replication
- upgrades

## Service

- connect to deployment by using labels
- LoadBalancers

## Replica Set

- control scaling for Pods

## Storage

- pv (persistent volume): decoupling storage of pod
- pv has pvc (persistent volume claim) for connecting with volume inside of pod, which can be used by containers


## Explore APIs

- `kubectl api-resources` command: show API Groups and Resources within the APIs
- `kubectl proxy + curl`
- `kubectl api-versions`
- `kubectl explain`

## Yaml file

- Default way to define API Objects
- A DevOps way to define API Objects:
  - whatevery you do, It's easy to reproduce
  - can be automated with CI/CD, ...
  - can be controled by VSC
  - can be shared to other developers & DevOps

## Init Containers

- used to prepare something before the app container run
- containers spec will only start after initContainers spec completed

## StatefulSets


## DaemonSets


## Storage - PV & PVC

## ConfigMaps - Secrets

## Helm - K8s package manager