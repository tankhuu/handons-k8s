# Pilot instance to deploy k8s cluster

- OS: Ubuntu
- Software:
  - 


## Create keypair

```
keyName=k8s
aws ec2 create-key-pair --key-name $keyName --output text --query "[KeyMaterial]" > ~/.ssh/k8s.pem
chmod 600 ~/.ssh/k8s.pem
```

