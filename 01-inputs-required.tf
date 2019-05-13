
variable "name" {
  description = "Name of Service"  #"__name__"
}

variable "location" {
  description = "Location" #"__location__"
}

variable "key_vault_uri" {
  description =  "Please use when setup in pipeline" #"https://__name__-kvs.vault.azure.net/"
}

variable "virtual_machine_name" {
  description =  "Please use when setup in pipeline" #"__name__-vm"
}

variable "vm_count" {
    default = 1
}

variable "vnet" {
  default = "10.97."
}

variable "smtp_email_address" {
  description = "Smtp Address to configure IIS SMTP"
}

variable "smtp_password" {
  description = "SMTP Password for Authentication"
}

