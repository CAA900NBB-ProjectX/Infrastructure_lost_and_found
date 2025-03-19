variable "FoundIt_rg" {
  description = "The name of the resource group"
  type        = string
  default     = "FoundIt_rg"
}

variable "location" {
  description = "The Azure region"
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet"
}

variable "public_subnet_name" {
  description = "The name of the public subnet"
  type        = string
  default     = "public_subnet"
}

variable "private_subnet_name" {
  description = "The name of the private subnet"
  type        = string
  default     = "private_subnet"
}

variable "vm_public_ip_name" {
  description = "The name of the public IP for the virtual machine"
  type        = string
  default     = "vm_public_ip"
}

variable "ssh_public_key" {
  description = "Path to the SSH public key"
  type        = string
  default     = "C:\\Users\\16475\\.ssh"
}

variable "ssh_private_key" {
  description = "Path to the SSH private key"
  type        = string
  default     = "C:\\Users\\16475\\.ssh"
}
