# terraform-azurerm-compute

[![Build Status](https://travis-ci.org/Azure/terraform-azurerm-compute.svg?branch=master)](https://travis-ci.org/Azure/terraform-azurerm-compute)

## Deploys 1+ Virtual Machines to your provided VNet

This Terraform module deploys Virtual Machines in Azure with the following characteristics:

- Ability to specify a simple string to get the [latest marketplace image](https://docs.microsoft.com/cli/azure/vm/image?view=azure-cli-latest) using `var.vm_os_simple`
- All VMs use [managed disks](https://azure.microsoft.com/services/managed-disks/)
- Network Security Group (NSG) created with a single remote access rule which opens `var.remote_port` port or auto calculated port number if using `var.vm_os_simple` to all nics
- VM nics attached to a single virtual network subnet of your choice (new or existing) via `var.vnet_subnet_id`.
- Control the number of Public IP addresses assigned to VMs via `var.nb_public_ip`. Create and attach one Public IP per VM up to the number of VMs or create NO public IPs via setting `var.nb_public_ip` to `0`.

> Note: Terraform module registry is incorrect in the number of required parameters since it only deems required based on variables with non-existent values.  The actual minimum required variables depends on the configuration and is specified below in the usage.

## Usage

This contains the bare minimum options to be configured for the VM to be provisioned.  The entire code block provisions a Windows and a Linux VM, but feel free to delete one or the other and corresponding outputs. The outputs are also not necessary to provision, but included to make it convenient to know the address to connect to the VMs after provisioning completes.

Provisions an Ubuntu Server 16.04-LTS VM and a Windows 2016 Datacenter Server VM using `vm_os_simple` to a new VNet and opens up ports 22 for SSH and 3389 for RDP access via the attached public IP to each VM.  All resources are provisioned into the default resource group called `terraform-compute`.  The Ubuntu Server will use the ssh key found in the default location `~/.ssh/id_rsa.pub`.

```hcl
provider "azurerm" {
  features {}
}

module "host_instance_2" {
  source = "../../"

  resource_group_name          = azurerm_resource_group.test.name
  disk_encryption_key_vault_id = azurerm_key_vault.test.id
  ad_group_deploiement_id      = var.ad_group_deploiement_id
  vm_hostname                  = "test-service"
  vm_config                    = var.vm_config
  is_windows_image             = true

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  nics = {
    default = {
      name      = "default"
      subnet_id = azurerm_subnet.subnet2.id
      asg       = []
      rules = {
        inbound  = []
        outbound = []
      }
    }
  }

  tags = local.tags
}
```

## Test

### Configurations

- [Configure Terraform for Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)
- [Generate and add SSH Key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) Save the key in ~/.ssh/id_rsa.  This is not required for Windows deployments.

We provide 2 ways to build, run, and test the module on a local development machine.  [Native (Mac/Linux)](#native-maclinux) or [Docker](#docker).

### Native (Mac/Linux)

#### Prerequisites

- [Ruby **(~> 2.3)**](https://www.ruby-lang.org/en/downloads/)
- [Bundler **(~> 1.15)**](https://bundler.io/)
- [Terraform **(~> 0.11.7)**](https://www.terraform.io/downloads.html)
- [Golang **(~> 1.10.3)**](https://golang.org/dl/)

#### Quick Run

We provide simple script to quickly set up module development environment:

```sh
$ curl -sSL https://raw.githubusercontent.com/Azure/terramodtest/master/tool/env_setup.sh | sudo bash
```

Then simply run it in local shell:

```sh
$ cd $GOPATH/src/{directory_name}/
$ bundle install
$ rake build
$ rake e2e
```

### Docker

We provide a Dockerfile to build a new image based `FROM` the `microsoft/terraform-test` Docker hub image which adds additional tools / packages specific for this module (see Custom Image section).  Alternatively use only the `microsoft/terraform-test` Docker hub image [by using these instructions](https://github.com/Azure/terraform-test).

#### Prerequisites

- [Docker](https://www.docker.com/community-edition#/download)

#### Custom Image

This builds the custom image:

```sh
$ docker build --build-arg BUILD_ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID --build-arg BUILD_ARM_CLIENT_ID=$ARM_CLIENT_ID --build-arg BUILD_ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET --build-arg BUILD_ARM_TENANT_ID=$ARM_TENANT_ID -t azure-compute .
```

This runs the build and unit tests:

```sh
$ docker run --rm azure-compute /bin/bash -c "bundle install && rake build"
```

This runs the end to end tests:

```sh
$ docker run --rm azure-compute /bin/bash -c "bundle install && rake e2e"
```

This runs the full tests:

```sh
$ docker run --rm azure-compute /bin/bash -c "bundle install && rake full"
```

## Authors

Originally created by [Redha Reghioua](http://github.com/redhareghioua)

## License

[MIT](LICENSE)
