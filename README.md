# ansible-role-k3s

Very very simple role to install k3s. No detailed configuration is possible.  
Only usable for quick and dirty test-cases

* Installs k3s from source
* Installs kubectl from source
* Copy `/etc/rancher/k3s/k3s.yaml` into `/root/.kube`

## Example usage
```
---
- hosts: k3s
  become: true
  roles:
    - tbauriedel.k3s
```