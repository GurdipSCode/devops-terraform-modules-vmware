# devops-terraform-modules-vmware

[![OpenTofu](https://img.shields.io/badge/OpenTofu-FFDA18?logo=opentofu&logoColor=black)](https://opentofu.org/)
[![VMware](https://img.shields.io/badge/VMware_vSphere-607078?logo=vmware&logoColor=white)](https://www.vmware.com/products/vsphere.html)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/your-org/terraform-vsphere-module?color=green)](https://github.com/your-org/terraform-vsphere-module/releases)

[![Buildkite](https://img.shields.io/buildkite/your-buildkite-badge-id/main?logo=buildkite&label=build)](https://buildkite.com/your-org/terraform-vsphere-module)
[![CodeRabbit](https://img.shields.io/badge/CodeRabbit-Enabled-blue?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0iI2ZmZiIgZD0iTTEyIDRjLTQuNDIgMC04IDMuNTgtOCA4czMuNTggOCA4IDggOC0zLjU4IDgtOC0zLjU4LTgtOC04eiIvPjwvc3ZnPg==)](https://coderabbit.ai)
[![Security](https://img.shields.io/badge/Security-Trivy-1904DA?logo=aquasecurity&logoColor=white)](https://trivy.dev/)
[![Checkov](https://img.shields.io/badge/Checkov-Passing-4CAF50?logo=paloaltonetworks&logoColor=white)](https://www.checkov.io/)

---

OpenTofu module for managing [VMware vSphere](https://www.vmware.com/products/vsphere.html) resources including virtual machines, datastores, networks, clusters, and resource pools.

## ✨ Features

- 🖥️ Create and manage virtual machines
- 📦 Configure datastores and storage policies
- 🌐 Manage distributed virtual switches and port groups
- 🏢 Set up clusters and resource pools
- 📋 Deploy from templates and content libraries
- 🔐 Manage permissions and roles
- 📸 Configure snapshots and backups
- 🏷️ Apply tags and custom attributes

## 📋 Requirements

| Name | Version |
|------|---------|
| ![OpenTofu](https://img.shields.io/badge/-OpenTofu-FFDA18?logo=opentofu&logoColor=black&style=flat-square) | `>= 1.6.0` |
| ![vSphere](https://img.shields.io/badge/-vSphere-607078?logo=vmware&logoColor=white&style=flat-square) | `>= 2.6.0` |

## 🚀 Usage

### Basic Virtual Machine

```hcl
module "vsphere" {
  source  = "your-org/vsphere/vsphere"
  version = "1.0.0"

  datacenter = "DC01"
  cluster    = "Cluster01"
  datastore  = "Datastore01"

  virtual_machines = {
    web_server = {
      name             = "web-server-01"
      template         = "ubuntu-22.04-template"
      num_cpus         = 2
      memory           = 4096
      network          = "VM Network"
      ipv4_address     = "10.0.1.10"
      ipv4_netmask     = 24
      ipv4_gateway     = "10.0.1.1"
      dns_server_list  = ["10.0.1.2"]
    }
  }
}
```

### VM with Multiple Disks and Networks

```hcl
module "vsphere" {
  source  = "your-org/vsphere/vsphere"
  version = "1.0.0"

  datacenter = "DC01"
  cluster    = "Cluster01"
  datastore  = "Datastore01"

  virtual_machines = {
    db_server = {
      name       = "db-server-01"
      template   = "rhel-9-template"
      num_cpus   = 8
      memory     = 32768
      folder     = "Databases"

      disks = [
        {
          label            = "disk0"
          size             = 100
          thin_provisioned = true
        },
        {
          label            = "disk1"
          size             = 500
          thin_provisioned = false
          datastore        = "SSD-Datastore"
        }
      ]

      networks = [
        {
          network      = "Production-Network"
          ipv4_address = "10.0.10.20"
          ipv4_netmask = 24
        },
        {
          network      = "Backup-Network"
          ipv4_address = "10.0.20.20"
          ipv4_netmask = 24
        }
      ]

      ipv4_gateway    = "10.0.10.1"
      dns_server_list = ["10.0.1.2", "10.0.1.3"]
    }
  }
}
```

### Complete Example

```hcl
module "vsphere" {
  source  = "your-org/vsphere/vsphere"
  version = "1.0.0"

  # 🏢 Infrastructure
  datacenter = "DC01"
  cluster    = "Production-Cluster"
  datastore  = "vSAN-Datastore"

  # 📁 Folders
  folders = {
    web_tier = {
      path = "Production/Web"
      type = "vm"
    }
    app_tier = {
      path = "Production/App"
      type = "vm"
    }
    db_tier = {
      path = "Production/Database"
      type = "vm"
    }
  }

  # 🏊 Resource Pools
  resource_pools = {
    production = {
      name                    = "Production"
      cpu_share_level         = "high"
      memory_share_level      = "high"
      cpu_reservation         = 8000
      memory_reservation      = 32768
      cpu_expandable          = true
      memory_expandable       = true
    }
    development = {
      name                    = "Development"
      cpu_share_level         = "normal"
      memory_share_level      = "normal"
      cpu_expandable          = true
      memory_expandable       = true
    }
  }

  # 🖥️ Virtual Machines
  virtual_machines = {
    # Web Tier
    web_01 = {
      name          = "web-prod-01"
      template      = "ubuntu-22.04-template"
      folder        = "Production/Web"
      resource_pool = "Production"
      num_cpus      = 4
      memory        = 8192

      disks = [
        {
          label            = "disk0"
          size             = 50
          thin_provisioned = true
        }
      ]

      networks = [
        {
          network      = "Web-Network"
          ipv4_address = "10.0.1.10"
          ipv4_netmask = 24
        }
      ]

      ipv4_gateway    = "10.0.1.1"
      dns_server_list = ["10.0.0.2"]

      extra_config = {
        "guestinfo.metadata"          = base64encode(local.cloud_init_metadata)
        "guestinfo.metadata.encoding" = "base64"
        "guestinfo.userdata"          = base64encode(local.cloud_init_userdata)
        "guestinfo.userdata.encoding" = "base64"
      }

      tags = ["environment:production", "tier:web"]
    }

    web_02 = {
      name          = "web-prod-02"
      template      = "ubuntu-22.04-template"
      folder        = "Production/Web"
      resource_pool = "Production"
      num_cpus      = 4
      memory        = 8192

      disks = [
        {
          label            = "disk0"
          size             = 50
          thin_provisioned = true
        }
      ]

      networks = [
        {
          network      = "Web-Network"
          ipv4_address = "10.0.1.11"
          ipv4_netmask = 24
        }
      ]

      ipv4_gateway    = "10.0.1.1"
      dns_server_list = ["10.0.0.2"]

      tags = ["environment:production", "tier:web"]
    }

    # App Tier
    app_01 = {
      name          = "app-prod-01"
      template      = "rhel-9-template"
      folder        = "Production/App"
      resource_pool = "Production"
      num_cpus      = 8
      memory        = 16384

      disks = [
        {
          label            = "disk0"
          size             = 100
          thin_provisioned = true
        },
        {
          label            = "disk1"
          size             = 200
          thin_provisioned = true
        }
      ]

      networks = [
        {
          network      = "App-Network"
          ipv4_address = "10.0.2.10"
          ipv4_netmask = 24
        }
      ]

      ipv4_gateway    = "10.0.2.1"
      dns_server_list = ["10.0.0.2"]

      tags = ["environment:production", "tier:app"]
    }

    # Database Tier
    db_01 = {
      name          = "db-prod-01"
      template      = "rhel-9-template"
      folder        = "Production/Database"
      resource_pool = "Production"
      num_cpus      = 16
      memory        = 65536

      disks = [
        {
          label            = "disk0"
          size             = 100
          thin_provisioned = false
        },
        {
          label            = "disk1"
          size             = 1000
          thin_provisioned = false
          datastore        = "SSD-Datastore"
        },
        {
          label            = "disk2"
          size             = 500
          thin_provisioned = false
          datastore        = "SSD-Datastore"
        }
      ]

      networks = [
        {
          network      = "Database-Network"
          ipv4_address = "10.0.3.10"
          ipv4_netmask = 24
        },
        {
          network      = "Backup-Network"
          ipv4_address = "10.0.100.10"
          ipv4_netmask = 24
        }
      ]

      ipv4_gateway    = "10.0.3.1"
      dns_server_list = ["10.0.0.2"]

      scsi_controller_count = 2
      scsi_type             = "pvscsi"

      tags = ["environment:production", "tier:database"]
    }
  }

  # 🌐 Distributed Virtual Switch
  distributed_switches = {
    production_dvs = {
      name    = "Production-DVS"
      version = "7.0.3"
      hosts   = ["esxi-01.example.com", "esxi-02.example.com", "esxi-03.example.com"]
      uplinks = ["uplink1", "uplink2"]

      port_groups = {
        web = {
          name      = "Web-Network"
          vlan_id   = 10
          num_ports = 128
        }
        app = {
          name      = "App-Network"
          vlan_id   = 20
          num_ports = 128
        }
        database = {
          name      = "Database-Network"
          vlan_id   = 30
          num_ports = 64
        }
        backup = {
          name      = "Backup-Network"
          vlan_id   = 100
          num_ports = 64
        }
      }
    }
  }

  # 🏷️ Tags
  tag_categories = {
    environment = {
      name        = "environment"
      cardinality = "SINGLE"
      types       = ["VirtualMachine", "Datastore"]
    }
    tier = {
      name        = "tier"
      cardinality = "SINGLE"
      types       = ["VirtualMachine"]
    }
    backup = {
      name        = "backup"
      cardinality = "SINGLE"
      types       = ["VirtualMachine"]
    }
  }

  tags = {
    prod = {
      name        = "production"
      category_id = "environment"
    }
    dev = {
      name        = "development"
      category_id = "environment"
    }
    web = {
      name        = "web"
      category_id = "tier"
    }
    app = {
      name        = "app"
      category_id = "tier"
    }
    database = {
      name        = "database"
      category_id = "tier"
    }
    daily = {
      name        = "daily"
      category_id = "backup"
    }
  }

  global_tags = {
    ManagedBy   = "opentofu"
    Environment = "production"
    Team        = "platform"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## 📥 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `datacenter` | vSphere datacenter name | `string` | n/a | yes |
| `cluster` | vSphere cluster name | `string` | n/a | yes |
| `datastore` | Default datastore name | `string` | n/a | yes |
| `virtual_machines` | Map of VMs to create | `map(object({ name = string, template = string, num_cpus = number, memory = number, ... }))` | `{}` | no |
| `folders` | Map of VM folders to create | `map(object({ path = string, type = string }))` | `{}` | no |
| `resource_pools` | Map of resource pools to create | `map(object({ name = string, cpu_share_level = string, memory_share_level = string }))` | `{}` | no |
| `distributed_switches` | Map of distributed virtual switches | `map(object({ name = string, version = string, hosts = list(string) }))` | `{}` | no |
| `tag_categories` | Map of tag categories to create | `map(object({ name = string, cardinality = string, types = list(string) }))` | `{}` | no |
| `tags` | Map of tags to create | `map(object({ name = string, category_id = string }))` | `{}` | no |
| `global_tags` | Tags to apply to all resources | `map(string)` | `{}` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| `vm_ids` | Map of VM names to their managed object IDs |
| `vm_ips` | Map of VM names to their IP addresses |
| `vm_moids` | Map of VM names to their MOIDs |
| `folder_paths` | Map of folder names to their paths |
| `resource_pool_ids` | Map of resource pool names to their IDs |
| `dvs_ids` | Map of DVS names to their IDs |
| `port_group_ids` | Map of port group names to their IDs |
<!-- END_TF_DOCS -->

## ⚙️ Provider Configuration

Configure the vSphere provider in your root module:

```hcl
terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.6.0"
    }
  }
}

provider "vsphere" {
  vsphere_server       = var.vsphere_server       # Or set VSPHERE_SERVER env var
  user                 = var.vsphere_user         # Or set VSPHERE_USER env var
  password             = var.vsphere_password     # Or set VSPHERE_PASSWORD env var
  allow_unverified_ssl = var.allow_unverified_ssl
}
```

## 📂 Examples

| Example | Description |
|---------|-------------|
| [🟢 Basic](./examples/basic) | Single VM deployment |
| [🔵 Complete](./examples/complete) | Multi-tier application stack |
| [🟣 Cluster](./examples/cluster) | Cluster and resource pool setup |
| [🟠 Networking](./examples/networking) | DVS and port group configuration |
| [🔴 Templates](./examples/templates) | Content library and template deployment |

## 🔒 Security Considerations

> ⚠️ **Important Security Notes**

| Item | Recommendation |
|------|----------------|
| 🔑 Credentials | Store in Vault or secure secrets manager |
| 🔐 Service Account | Use dedicated service account with minimal permissions |
| 🌐 Network | Use isolated management network for vCenter access |
| 📋 RBAC | Follow least-privilege for vSphere roles |
| 🔒 SSL | Enable SSL verification in production |
| 📸 Snapshots | Automate snapshot cleanup policies |

## 🔄 Migration Guide

### v0.x → v1.0

> ⚠️ **Breaking changes in v1.0**

| Change | Before (v0.x) | After (v1.0) |
|--------|---------------|--------------|
| VMs | `vm` | `virtual_machines` (map) |
| Disks | `disk_size` | `disks` (list) |
| Networks | `network_interface` | `networks` (list) |

```hcl
# ❌ Before (v0.x)
module "vsphere" {
  source    = "your-org/vsphere/vsphere"
  version   = "0.5.0"
  vm_name   = "web-server"
  disk_size = 100
}

# ✅ After (v1.0)
module "vsphere" {
  source  = "your-org/vsphere/vsphere"
  version = "1.0.0"
  virtual_machines = {
    web = {
      name = "web-server"
      disks = [{ label = "disk0", size = 100 }]
    }
  }
}
```

## 🤝 Contributing

1. 🍴 Fork the repository
2. 🌿 Create a feature branch (`git checkout -b feat/new-feature`)
3. 💾 Commit changes using [Conventional Commits](https://www.conventionalcommits.org/)
4. 📤 Push to the branch (`git push origin feat/new-feature`)
5. 🔃 Open a Pull Request

### 📝 Commit Message Format

```
<type>(<scope>): <description>
```

| Type | Description |
|------|-------------|
| `feat` | ✨ New feature |
| `fix` | 🐛 Bug fix |
| `docs` | 📚 Documentation |
| `refactor` | ♻️ Code refactoring |
| `test` | 🧪 Tests |
| `chore` | 🔧 Maintenance |

**Scopes:** `vms`, `networking`, `storage`, `clusters`, `templates`, `examples`, `docs`

### 🛠️ Local Development

```bash
# 🎨 Format code
tofu fmt -recursive

# ✅ Validate
tofu validate

# 📖 Generate docs
terraform-docs markdown table . > README.md

# 🧪 Run tests
cd examples/basic && tofu init && tofu plan
```

## 📄 License

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

Apache 2.0 - See [LICENSE](LICENSE) for details.

## 👥 Authors

Maintained by **Your Organization**.

## 🔗 Related

| Resource | Link |
|----------|------|
| 📖 vSphere Documentation | [docs.vmware.com](https://docs.vmware.com/en/VMware-vSphere/index.html) |
| 🔌 vSphere Provider | [Registry](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs) |
| 🔧 vSphere API | [API Reference](https://developer.vmware.com/apis/vsphere-automation/latest/) |
| 📋 PowerCLI | [PowerCLI Docs](https://developer.vmware.com/powercli) |
| 🟡 OpenTofu | [opentofu.org](https://opentofu.org/) |
| 🟢 Buildkite | [buildkite.com](https://buildkite.com/) |

---

<p align="center">
  <sub>Built with ❤️ using <img src="https://img.shields.io/badge/-OpenTofu-FFDA18?logo=opentofu&logoColor=black&style=flat-square" alt="OpenTofu" /> and <img src="https://img.shields.io/badge/-Buildkite-14CC80?logo=buildkite&logoColor=white&style=flat-square" alt="Buildkite" /></sub>
</p>
