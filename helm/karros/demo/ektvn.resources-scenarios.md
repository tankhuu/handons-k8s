# Helm Chart Demo - Resources & Scenarios

## Benefits

- Templating Services.
- Consistent, Reusable, Repeatable, easier on Managing.
- Version Control.
- Automation powered by Jenkins and/or Ansible.
- Help to manage history of deployments/changes in revision which will be very useful for:
  - identifying service version in a deployment
  - rollback base-on deployment (multiple related services) by revision,
  - ...

## Helm Private Repository

- GitHub: https://github.com/eduloginc/devops-helm-charts/tree/main/s3Repo
- RepoName: stable-athena (S3)
- S3 Path: s3://athena-pre-helm-charts/stable/athena

## Helm Charts

- Athena: https://github.com/eduloginc/devops-helm-charts/tree/main/athena
- Others: https://github.com/eduloginc/devops-helm-charts

## Helm Concepts

Chart: -> CloudFormation Template

![Main Chart: Athena](/img/tree-athena.png)

Chart Dependencies: -> CloudFormation Nested Stack Template

![Dependency Chart: GeocodeService](/img/tree-geocodeservice.png)

Release: -> Site

Templates: -> deployment, service, hpa, ...

Values: -> Configs , Versions

## AWS Resources

Still Provisioned by CloudFormation Templates

- Frontend: https://ektvn.athena-nonprod.com
- WebQuery: https://webquery-ektvn.athena-nonprod.com
- WOSNOS Instance
- RDS Instance: athena-ektvn-rds

## Helm Demo Athena

Backend: https://ath-be-ektvn.athena-nonprod.com/swagger-ui.html

0. preparation

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

```

1. provision new site

> provision site with core services

ektvn.v1.values.yaml

    gateway: e56829fdd2dce32a9616cb083471b04e8534ef7a
    tnxhubservice: f4035225dfc322712cf3908522f317d30c8be0e8
    routingservice: a302114c786379f776b038c3260c908d7699574d
    geocodeservice:
    cac1284f42c59ffb535e8c57268555408f151fa6

commands:

```
## Create namespace
kubectl create namespace $site

## deploy cache & queue
helm -n $site install --wait -f "${site}-cache.values.yaml" mongodb bitnami/mongodb

helm -n $site install --wait -f "${site}-queue.values.yaml" rabbitmq bitnami/rabbitmq

## Deploy Backend Services
helm -n $site install --wait -f ektvn.v1.values.yaml $site $chartName

## Check swagger
https://ath-be-ektvn.athena-nonprod.com/swagger-ui.html
```

2. provision group of services base on feature

> provision with feature RideRegistration

ektvn.v2.values.yaml

    aggregateservice: 556d30fbb516fe070723fc3669436b046372a123

_Note on option --reuse-values otherwise everything will be a chaos_

```
helm -n $site upgrade --reuse-values --wait -f ektvn.v2.values.yaml $site $chartName
```

> provision with feature MapOverlay

ektvn.v3.values.yaml

    overlayservice: 1cc4d26003764a8e738130faf4feb250a572498d

```
helm -n $site upgrade --reuse-values --wait -f ektvn.v3.values.yaml $site $chartName
```

3. upgrade version of 1 or some services

> upgrade version of tnxhub & routing

ektvn.v4.values.yaml

    aggregateservice: d3fad5fa3b51be2cc425b0868d949edc69e8125b
    routingservice: f4035225dfc322712cf3908522f317d30c8be0e8

```
helm -n $site upgrade --reuse-values --wait -f ektvn.v4.values.yaml $site $chartName
```

> upgrade version of geocodeservice

ektvn.v5.values.yaml

    geocodeservice: c562c76e888f3356f33338530628b5c83a7b8557

```
helm -n $site upgrade --reuse-values --wait -f ektvn.v5.values.yaml $site $chartName
```

4. rollback with revision

> List out revisions history & values

```
helm -n $site history $site

helm -n $site get values $site --revision <REVISION>

helm -n $site rollback $site <REVISION>
```

## Next steps

- Complete Charts with remaining services.
- Remove a feature from a namespace if needed. -> latest test passed.
- Jenkins Jobs for provision EKS Resources
- Jenkins Job for upgrade services
- List out the scenarios that should be consider in deployment or management

## Errors

### routingservice

```
at org.springframework.beans.factory.support.AbstractBeanFactory.lambda$doGetBean$0(AbstractBeanFactory.java:320)
at org.springframework.beans.factory.support.DefaultSingletonBeanRegistry.getSingleton(DefaultSingletonBeanRegistry.java:222)
at org.springframework.beans.factory.support.AbstractBeanFactory.doGetBean(AbstractBeanFactory.java:318)
at org.springframework.beans.factory.support.AbstractBeanFactory.getBean(AbstractBeanFactory.java:199)
at org.springframework.beans.factory.config.DependencyDescriptor.resolveCandidate(DependencyDescriptor.java:273)
at org.springframework.beans.factory.support.DefaultListableBeanFactory.doResolveDependency(DefaultListableBeanFactory.java:1239)
at org.springframework.beans.factory.support.DefaultListableBeanFactory.resolveDependency(DefaultListableBeanFactory.java:1166)
at org.springframework.beans.factory.annotation.AutowiredAnnotationBeanPostProcessor$AutowiredFieldElement.inject(AutowiredAnnotationBeanPostProcessor.java:593)
... 105 common frames omitted
Caused by: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'dataMapper': Invocation of init method failed; nested exception is java.lang.ClassCastException
at org.springframework.beans.factory.annotation.InitDestroyAnnotationBeanPostProcessor.postProcessBeforeInitialization(InitDestroyAnnotationBeanPostProcessor.java:139)
at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.applyBeanPostProcessorsBeforeInitialization(AbstractAutowireCapableBeanFactory.java:419)
at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.initializeBean(AbstractAutowireCapableBeanFactory.java:1737)
at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.doCreateBean(AbstractAutowireCapableBeanFactory.java:576)
at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.createBean(AbstractAutowireCapableBeanFactory.java:498)
at org.springframework.beans.factory.support.AbstractBeanFactory.lambda$doGetBean$0(AbstractBeanFactory.java:320)
at org.springframework.beans.factory.support.DefaultSingletonBeanRegistry.getSingleton(DefaultSingletonBeanRegistry.java:222)
at org.springframework.beans.factory.support.AbstractBeanFactory.doGetBean(AbstractBeanFactory.java:318)
at org.springframework.beans.factory.support.AbstractBeanFactory.getBean(AbstractBeanFactory.java:199)
at org.springframework.beans.factory.config.DependencyDescriptor.resolveCandidate(DependencyDescriptor.java:273)
at org.springframework.beans.factory.support.DefaultListableBeanFactory.doResolveDependency(DefaultListableBeanFactory.java:1239)
at org.springframework.beans.factory.support.DefaultListableBeanFactory.resolveDependency(DefaultListableBeanFactory.java:1166)
at org.springframework.beans.factory.annotation.AutowiredAnnotationBeanPostProcessor$AutowiredFieldElement.inject(AutowiredAnnotationBeanPostProcessor.java:593)
... 118 common frames omitted
Caused by: java.lang.ClassCastException: n
```
