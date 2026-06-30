# ansible-role-k3s

Ready to use K3s cluster. All in one deployment inspired by the concepts of OpenShift.
Supports installation of the common components. ArgoCD, kube-vip for HA and NFS storage driver.

The packages needed for K3s are fetched from the official K3s GitHub repository itself during installation.

At the moment, no air-gapped installation is supported.
In case you want to have an air-gapped installation, you can skip the installation and only configure / manage your k3s node / cluster with the role.

General K3s documentation can be found here: https://docs.k3s.io/

> Most of the configurations for K3s needs to be done while cluster installation. The ansible-role-k3s is intended to use as a installation role, not for changing the configuration afterwards!


## About

The role will install K3s on the target hosts. Standalone and clusters with more than one node is supported.

Supports installation of the kubernetes-csi driver and argocd out-of-the-box. Check variables for details!

## Requirements

A working name resolution must be in place.

## Variables

General variables with default values.

### Installation

|  Variable | Default | Description |
|---|---|---|
| k3s_skip_installation | `false` |  Skip installation of packages and images. Can be used to have an air-gapped instalation. Ensure the needed packages are installed before using the role! |
| k3s_version | `1.33.12` | Release that will be installed |
| k3s_binary_source | `https://github.com/k3s-io/k3s/releases/download/v{{ k3s_release }}%2Bk3s1/k3s` | Source URL to fetch k3s binary via HTTP(S) |
| k3s_binary_path | `/usr/local/bin/k3s` | Local file path to store binary |
| k3s_version_kubectl | `1.36.0` | Release that will be installed for kubectl |
| k3s_binary_source_kubectl | `https://dl.k8s.io/release/v{{ k3s_version_kubectl }}/bin/linux/amd64/kubectl` | Source URL to fetch kubectl binary via HTTP(S) |
| k3s_binary_path_kubectl | `/usr/local/bin/kubectl` | Local file path to store binary for kubectl |
| k3s_enable_kubectl_auto_completion | `true` | Enable kubectl auto-completion for become_user |

### Configuration

|  Variable | Default | Description |
|---|---|---|
| k3s_node_type | `server` | Type of node (agent or server) |
| k3s_config_cluster_init | `true` | Configure node to initialize the cluster |
| k3s_config_cluster_domain | `cluster.local` | Domain for your k3s cluster |
| k3s_config_cluster_cidr | `10.42.0.0/16` | CIDR for pods |
| k3s_config_service_cidr | `10.43.0.0/16` | CIDR for services |
| k3s_config_cluster_dns | `10.43.0.10` | IPv4 for the CoreDNS (should be part of the service cidrs) |
| k3s_config_nodeport_range | `30000-32767` | Range for NodePorts |
| k3s_config_init_server | `localhost` | Server to connecto to, used to join a cluster. Only needed when joining nodes to a cluster. As default / dummy value, localhost is defined |
| k3s_config_disable_local_storage | `false` | Disable the local storageclass |
| k3s_traefik_tls | `false` | Enable TLS by default for the treafik ingress |
| k3s_traefik_tls_key | `""` | Base64 encoded string of the key to use |
| k3s_traefik_tls_crt | `""` | Base64 encoded string of the certificate (chain) to use |
| k3s_storage_nfs | `false` | Install csi-nfs storage driver |
| k3s_storage_nfs_chart_version | `4.13.3` | Chart version to install csi-nfs driver |
| k3s_storage_nfs_create_storageclass | `false` | Create a storageclass for nfs-csi |
| k3s_storage_nfs_storageclass_name | `csi-nfs` | Name name for the created class |
| k3s_storage_nfs_server | `""` | NFS server that will be used |
| k3s_storage_nfs_server_share | `""` | Share / path used by the NFS storage driver |
| k3s_storage_nfs_reclaim_policy | `Delete` | Reclaim policy for the storage class |
| k3s_storage_nfs_volume_binding_mode | `Immediate` | Volume binding for storage class |
| k3s_storage_nfs_version | `4.1` | NFS version |
| k3s_argocd | `false` | Apply argocd to cluster (via helm) |
| k3s_argocd_chart_version | `3.4.4` | Chart version used to install argocd |
| k3s_argocd_ingress_hostname | `` | Ingress hostname to use argocd |
| k3s_kube_vip | `false` | Apply kube-vip to cluster |
| k3s_kube_vip_ipv4 | `""` | IPv4 that will be used for the cluster ip |
| k3s_kube_vip_interface | `""` | Interface to apply to |

### OS-specific variables

Some variables are os-specific or have different variables based on the OS.

**RHEL**

| Variable | Value | Description |
|---|---|---
| k3s_os_packages | `['container-selinux']` | Additional packages to install

## Example usage
```
---
- name: Add /etc/hosts entries to hosts
  hosts: all
  become: true
  tasks:
    - name: Fetch setup
      ansible.builtin.setup:

    - name: Add IP address of all hosts from inventory to all hosts
      ansible.builtin.lineinfile:
        dest: /etc/hosts
        regexp: '.*{{ item }}$'
        line: "{{ hostvars[item].ansible_default_ipv4.address }} {{ hostvars[item].ansible_fqdn }}"
        state: present
      when:
        - hostvars[item].ansible_fqdn is defined
        - hostvars[item].ansible_default_ipv4.address is defined
      with_items: "{{ groups['all'] }}"

- name: k3s-init # noqa name[casing]
  hosts: k3s-cluster-init
  become: true
  vars:
    k3s_kube_vip: true
    k3s_kube_vip_ipv4: 192.168.121.2
    k3s_kube_vip_interface: eth0
  roles:
    - tbauriedel.k3s

- name: k3s-joiner # noqa name[casing]
  hosts: k3s-cluster-joiner
  become: true
  vars:
    k3s_config_cluster_init: false
    k3s_config_init_server: k3s-test01
    k3s_kube_vip: true
    k3s_kube_vip_ipv4: 192.168.121.2
    k3s_kube_vip_interface: eth0
  roles:
    - tbauriedel.k3s
```

## Development

A makefile is shipped to lint the ansible role and test it against some hosts.
- `make` to run the linters.
- `make test` to install the role on your client and run the example playbook against local hosts (You will need to provide these hosts)

For local testing, molecule can be used. Scenarios are defined inside [./molecule](./molecule).  
Requirements:
- apt install podman
- python3 -m pip install molecule molecule-podman
```bash
molecule test
```

## License 

This project is licensed under the MIT License. See the LICENSE file for the full license text.