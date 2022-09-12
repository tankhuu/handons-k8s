# Handons Kubernetes Dashboard

## Setup

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml

cat << EOF > dashboard-adminuser.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

# Create user with role binding
kubectl apply -f dashboard-adminuser.yaml
# Get token
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
# Run Proxy to access Dashboard from localhost
kubectl proxy
# Access dashboard with token
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=default;dashboard-admin


curl -LO "https://dl.k8s.io/release/$(curl -LO "https://dl.k8s.io/release/v1.25.0/bin/darwin/amd64/kubectl")/bin/darwin/amd64/kubectl"