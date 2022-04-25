marine Instance
=========

Launch the marine instance in AWS to create K8s Cluster.
Install all necessary packages for using

Requirements
------------

Packages:
- [zsh (with power10k theme)](https://dev.to/abdfnx/oh-my-zsh-powerlevel10k-cool-terminal-1no0)
- [python3](https://www.python.org/downloads/)
- [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
  + `python3 -m pip install --user ansible`a
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

Preparation
------------

```
# Config default profile for AWS
aws configure
```

Setup Marine
------------

```
cd ansible
ansible-playbook deploy.yml
```