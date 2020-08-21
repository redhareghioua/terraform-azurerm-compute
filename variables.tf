variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."
}

variable "location" {
  description = "(Optional) The location in which the resources will be created."
  default     = ""
}

variable "public_ip_dns" {
  description = "Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb_public_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string."
  default     = [null]
}

variable "remote_port" {
  description = "Remote tcp port to be used for access to the vms created via the nsg applied to the nics."
  default     = ""
}

variable "custom_data" {
  description = "The custom data to supply to the machine. This can be used as a cloud-init for Linux systems."
  default     = ""
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  default     = "Standard_LRS"
}

variable "nb_instances" {
  description = "Specify the number of vm instances."
  default     = "1"
}

variable "vm_hostname" {
  description = "local name of the Virtual Machine."
  default     = "myvm"
}

variable "vm_os_simple" {
  description = "Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os.  Do not provide this value if a custom value is used for vm_os_publisher, vm_os_offer, and vm_os_sku."
  type        = string
  default     = ""
}

variable "vm_os_id" {
  description = "The resource ID of the image that you want to deploy if you are using a custom image.Note, need to provide is_windows_image = true for windows custom images."
  default     = ""
}

variable "is_windows_image" {
  description = "Boolean flag to notify when the custom image is windows based."
  default     = false
}

variable "plan" {
  description = "Plan de la VM en cas de Virtual Appliance"
  default = {
    name      = ""
    publisher = ""
    product   = ""
  }
}

variable "source_image_reference" {
  description = "Source image reference of the image that you want to deploy with : publisher, offer, sku and version values"
  default = {
    publisher = ""
    offer     = ""
    sku       = ""
    version   = ""
  }
}

variable "source_image_id" {
  description = "Source image id of the image that you want to deploy"
  default     = ""
}

variable "nics" {
  description = "The nics of the virtual machines will be created, with the following properties :"

  default = {
    name      = ""
    subnet_id = ""
    asg       = []
    rules = {
      address_prefixes = []
      inbound = [{
        name     = ""
        ports    = []
        protocol = ""
      }]
      outbound = [{
        name     = ""
        ports    = []
        protocol = ""
      }]
    }
  }
}

variable "vm_config" {
  default = {
    vm_size        = "Standard_LRS"
    ssh_key_path   = "~/.ssh/id_rsa.pub"
    admin_username = "administrateur"
    admin_password = ""
  }
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

variable "allocation_method" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  default     = "Dynamic"
}

variable "nb_public_ip" {
  description = "Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses."
  default     = "1"
}

variable "data_sa_type" {
  description = "Data Disk Storage Account type."
  default     = "Standard_LRS"
}

variable "data_disk_size_gb" {
  description = "Storage data disk size size."
  default     = 30
}

variable "boot_diagnostics" {
  type        = bool
  description = "(Optional) Enable or Disable boot diagnostics."
  default     = false
}
variable "boot_diagnostics_uri" {
  description = "(Optional) The uri of the storage account to store the boot diagnostics of the vm"
  default     = ""
}


variable "boot_diagnostics_sa_type" {
  description = "(Optional) Storage account type for boot diagnostics."
  default     = "Standard_LRS"
}

variable "enable_accelerated_networking" {
  type        = bool
  description = "(Optional) Enable accelerated networking on Network interface."
  default     = false
}

variable "enable_ssh_key" {
  type        = bool
  description = "(Optional) Enable ssh key authentication in Linux virtual Machine."
  default     = true
}

variable "nb_data_disk" {
  description = "(Optional) Number of the data disks attached to each virtual machine."
  default     = 0
}

variable "source_address_prefixes" {
  description = "(Optional) List of source address prefixes allowed to access var.remote_port."
  default     = ["0.0.0.0/0"]
}

variable "disk_encryption_key_vault_id" {
  description = "(Optional) Key vault id to be used to encrypt the vm's disk"
  default     = ""
}

variable "ad_group_deploiement_id" {
  description = "(required) ad group deploiement"
}
