variable "subscription_id" { }

variable "name" { }

variable "location" { }

variable "key_vault_uri" { }

variable "virtual_machine_name" { }

variable "vm_count" {
    default = 2
}

variable "vnet" {
  default = "10.97."
}

variable "environment" { }

variable "common_tags" {}