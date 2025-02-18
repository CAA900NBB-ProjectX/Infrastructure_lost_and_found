variable "FoundIt_rg" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region"
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "ssh_public_key" {
  description = "Path to the SSH public key"
  type        = string
}

variable "ssh_private_key" {
  description = "Path to the SSH private key"
  type        = string
}
