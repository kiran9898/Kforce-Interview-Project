terraform {
  required_version = ">=1.0.0"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">=3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name   = "devops-interview-gauntlet-x-kgouda"
    storage_account_name  = "terraformstatefiles0101"
    container_name        = "project-milestone-tfstatefiles"
    key                   = "MS-01-02-terraform.tfstate"
  }  
}

provider "azurerm" {
  features {}
  subscription_id = var.My_Subcription_ID
}
