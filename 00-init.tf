terraform {
  required_version                  = ">= 0.11.0"
  backend "azurerm" {}
}

provider "azurerm" {
  version                           = ">=1.24.0"
  subscription_id                   = "${var.subscription_id}"
}

provider "http" {
  version                           = ">=1.0"
}

provider "null" {
  version                           = ">=2.1"
}

provider "template" {
  version                           = ">=2.1"
}