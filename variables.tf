variable "resource_group_name" {
  description = "Name of an existing resource group."
  type        = string
  default     = "bastion"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "West Europe"
}

variable "bastion_name" {
  description = "String to name the bastion resources."
  type        = string
  default     = "bastion"
}

variable "admin_username" {
  description = "VM admin username."
  default     = "azureadmin"
}

variable "linux_server_name" {
  description = "String to name the Linux server resources."
  type        = string
  default     = "ubuntu"
}

variable "admin_ssh_public_key_file" {
  description = "Public key file to use."
  default     = "~/.ssh/id_rsa.pub"
}

variable "windows_server_name" {
  description = "String to name the Windows server resources."
  type        = string
  default     = "windows"
}

variable "windows_server_admin_password" {
  description = "Valid password for the Windows server."
  type        = string
  default     = null
}

variable "virtual_network_name" {
  description = "Name for an existing virtual network. Must contain an AzureBastionSubnet."
  type        = string
  default     = "bastion"
}

variable "address_space" {
  description = "Valid virtual network address space."
  type        = string
  default     = "172.19.76.0/25"

  validation {
    condition     = split("/", var.address_space)[1] < 26
    error_message = "The address_space value must be a valid CIDR with a subnet of at least /25."
  }
}

variable "subnet_name" {
  description = "Name of an existing subnet for the virtual machine(s)."
  type        = string
  default     = "vms"
}

variable "scale_units" {
  description = "Number of hosts used for the Bastion service. Increase if more connections are required."
  type        = number
  default     = 2
}

variable "virtual_machine_admins" {
  description = "Optional list of Azure Active Directory object IDs to assign the Virtual Machine Administrator Login role."
  type        = list(string)
  default     = []
}

variable "virtual_machine_users" {
  description = "List of Azure Active Directory object IDs to assign the Virtual Machine User Login role."
  type        = list(string)
  default     = []
}
