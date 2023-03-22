# Create token for node (workers) to join cluster
# At this point we could copy and paste the join command from the cp node. That command only works for 2 hours, so we will build our own join should we want to add nodes in the future. 
# Find the token on the cp node. The token lasts 2 hours by default. If it has been longer, and no token is present you can generate a new one with the sudo kubeadm token create command

# In cp
sudo kubeadm token list
# Save token for using later
sudo kubeadm token create 

# save key hash for using later
openssl x509 -pubkey \
  -in /etc/kubernetes/pki/ca.crt | openssl rsa \
  -pubin -outform der 2>/dev/null | openssl dgst \
  -sha256 -hex | sed 's/ˆ.* //' 

# In worker
# Token & Key got from command in cp
token="27eee4.6e66ff60318da929"
key="6d541678b05652e1fa5d43908e75e67376e994c3483d6683f2a18673e5d2a1b0"
sudo kubeadm join \
  --token $token \
  k8scp:6443 \
  --discovery-token-ca-cert-hash \
  sha256:$key