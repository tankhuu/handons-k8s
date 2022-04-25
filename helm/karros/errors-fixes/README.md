# Errors & Fixes Guideline

## Lint errors

### Error

```
helm lint $chartName                                                                        ✔  anaconda3   04:49:40 PM 
==> Linting athena
[INFO] Chart.yaml: icon is recommended
[ERROR] /Users/tankhuu/GitHub/Karros/devops-helm-charts/athena: chart metadata is missing these dependencies: rabbitmq,gateway

Error: 1 chart(s) linted, 1 chart(s) failed
```

### Fix

Remove the un-used charts in `charts/` directory which was un-used in `Chart.yaml` but exist in `charts/` directory.

```
rm -f /Users/tankhuu/GitHub/Karros/devops-helm-charts/athena/charts/rabbitmq-*
rm -f /Users/tankhuu/GitHub/Karros/devops-helm-charts/athena/charts/gateway-*
```
