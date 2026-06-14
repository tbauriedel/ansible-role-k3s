> Under development. Not finished yet!

# ansible-role-k3s

Install and configure k3s (standalone or cluster).

The packages needed for k3s are fetched from the official k3s GitHub repository itself during installation.

At the moment, no air-gapped installation is supported.
In case you want to have an air-gapped installation, you can skip the installation and only configure / manage your k3s node / cluster with the role.

General K3s documentation can be found here: https://docs.k3s.io/

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
| k3s_config_init_server | `groups['k3s-cluster-init'][0]` | Server to connecto to, used to join a cluster. Only needed when joining nodes to a cluster. By default the first host in group `k3s-cluster-init` will be used. |

### OS-specific variables

Some variables are os-specific or have different variables based on the OS.

**RHEL**

| Variable | Value | Description |
|---|---|---
| k3s_os_packages | ['container-selinux'] | Additional packages to install

## Example usage
```
---
- hosts: k3s
  become: true
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