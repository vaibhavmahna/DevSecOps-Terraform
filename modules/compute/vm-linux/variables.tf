variable "name" {
  type        = string
  description = "Name of the virtual machine."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy the virtual machine into."
}

variable "location" {
  type        = string
  description = "Azure region to deploy the virtual machine into."
}

variable "size" {
  type        = string
  description = "VM size (SKU)."
  default     = "Standard_B2s"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet the VM's network interface attaches to."
}

variable "admin_username" {
  type        = string
  description = "Admin username for the virtual machine."
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH public key for the admin user."
}

variable "os_disk_caching" {
  type        = string
  description = "Caching mode for the OS disk."
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  type        = string
  description = "Storage account type for the OS disk."
  default     = "Standard_LRS"
}

variable "image_publisher" {
  type        = string
  description = "Publisher of the source image."
  default     = "Canonical"
}

variable "image_offer" {
  type        = string
  description = "Offer of the source image."
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  type        = string
  description = "SKU of the source image."
  default     = "22_04-lts-gen2"
}

variable "image_version" {
  type        = string
  description = "Version of the source image."
  default     = "latest"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resources."
  default     = {}
}
