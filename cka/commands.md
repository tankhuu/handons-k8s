# List of useful commands in K8s

```
gcloud container clusters create k1

kubectl run nginx --image=nginx:1.15.7
kubectl run nginx --image=nginx:latest
kubectl expose deployments nginx --port=80 --type=LoadBalancer
kubectl get pods -l "app=nginx" -o yaml

kubectl api-resources | less

kubectl get pods -n kube-system

# kubectl auth can-i ..... # verify what you can do with current credentials
kubectl auth can-i create deployments 
kubectl auth can-i create pods --as linda
kubectl auth can-i create pods --as linda --namespace apps

kubectl api-versions

kubectl explain

kubectl cluster-info
kubectl cluster-info dump | less

kubectl -h | less

# Setup completion for easier to work with kubectl
# Remember to install bash-completion
kubectl completion bash > ~/.bashrc
kubectl completion bash > ~/.zshrc
kubectl completion bash > /etc/bash_completion.d/kubectl # allow completion work for everybody

kubectl create -f <config>.yaml

etcdctl | etcdctl2
ETCDCTL_API=3 etcdctl -h

sudo yum provides */etcdctl # search for provider of package

kubectl get

kubectl label

kubectl edit deployments.apps <pod-name>

kubectl rollout -h
kubectl rollout history deployment


# In a namespace
kubectl api-resources --namespaced=true

# Not in a namespace
kubectl api-resources --namespaced=false

# Label filtering
kubectl get pods -l environment=production,tier=frontend
kubectl get pods -l 'environment in (production),tier in (frontend)'
kubectl get pods -l 'environment in (production, qa)'
kubectl get pods -l 'environment,environment notin (frontend)'

# Use the kubectl exec command to run an interactive shell inside the Monolith Pod. This can come in handy when you want to troubleshoot from within a container:

`kubectl exec monolith --stdin --tty -c monolith -- /bin/sh`

## For example, once you have a shell into the monolith container you can test external connectivity using the ping command:

`ping -c 3 google.com`

## Be sure to log out when you're done with this interactive shell.

`exit`
```