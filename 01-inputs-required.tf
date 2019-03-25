
variable "name" {
  default = ""  #"__name__"
}

variable "location" {
  default = "" #"__location__"
}

variable "key_vault_uri" {
  default =  "" #"https://__name__-kvs.vault.azure.net/"
}

variable "virtual_machine_name" {
  default =  "" #"__name__-vm"
}

variable "vm_count" {
    default = 1
}

variable "vnet" {
  default = "10.97."
}
