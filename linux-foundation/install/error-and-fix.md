# Errors & Fixes

## 

## [ERROR CRI]: container runtime is not running [Issue Encountered]


> Error

```
sudo kubeadm join k8scp:6443 --token t807kd.bkogqr8exua1vl0c         --discovery-token-ca-cert-hash sha256:a603d4ce4ab877133f17daed892bea4a85ebccbe9d1d4b37d0e3322afe8f9e03
[preflight] Running pre-flight checks
error execution phase preflight: [preflight] Some fatal errors occurred:
	[ERROR CRI]: container runtime is not running: output: time="2023-03-19T05:40:51Z" level=fatal msg="validate service connection: CRI v1 runtime API is not implemented for endpoint \"unix:///var/run/containerd/containerd.sock\": rpc error: code = Unimplemented desc = unknown service runtime.v1.RuntimeService"
, error: exit status 1
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
To see the stack trace of this error execute with --v=5 or higher
```

> Fix

```
sudo rm /etc/containerd/config.toml
sudo systemctl restart containerd
sudo kubeadm init # or sudo kubeadm join
```

## Found multiple CRI endpoints on the host. Please define which one do you wish to use by setting the 'criSocket' field in the kubeadm configuration file: unix:///var/run/containerd/containerd.sock, unix:///var/run/cri-dockerd.sock

```
sudo systemctl stop cri-docker.socket
```
