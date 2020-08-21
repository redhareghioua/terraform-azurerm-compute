variable "location" {}
variable "location_alt" {}
variable "vm_os_simple_1" {}
variable "vm_os_simple_2" {}
variable "admin_username" {}
variable "admin_password" {}
variable "custom_data" {}
variable "vm_config" {
  default = {
    vm_size        = "Standard_LRS"
    ssh_key_path   = "~/.ssh/id_rsa.pub"
    admin_username = "administrateur"
    admin_password = ""
  }
}