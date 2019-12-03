variable "subscription_id" { }

variable "rg_name" { 
  default   = "hmcts-dmz-prod-sftp"
}

variable "rg_location" { 
  default   = "uksouth"
}

variable "common_tags" {}


variable "key_vault_uri" { }

variable "virtual_machine_name" { }

variable "vm_count" { }

variable "vnet" {
  default = "10.97."
}

variable "environment" { }


variable "admin-username" {}

variable "admin-password" {}

variable "smtp-email-address" {}

variable "smtp-password" {}
