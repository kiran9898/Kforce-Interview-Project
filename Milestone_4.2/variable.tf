variable "My_Subcription_ID" {
  type = string
}

variable "Location" {
  type = string
}
variable "Resource_Grp_Name" {
  type = string
}
 ### srorage name 

variable Storage_Account_Name {
  type = string
}



### - Subnet 1
variable Virtual_Network_Name {
  type = string
}

variable Vnet_Adrress_Space{
  type = list(string)
}

variable Subnet_Function_Name{
  type = string
}

variable Subnet_Function_Address_Prefixes{
  type = list(string)
}


variable Subnet_Function_Delegation_Name{
  type = string
}


### subnet 2
variable Subnet_Webapp_Name{
  type = string
}

variable "Subnet_Webapp_Address_Prefixes" {
  type = list(string)
}

variable Subnet_Webapp_Delegation_Name{
  type = string
}

## subnet 3

variable Subnet_for_Pvt_Endpnt_Name {
  type = string
}

variable "Subnet_for_Pvt_Endpnt_Adss_Pfx" {
  type = list(string)
}

variable "Private_DNS_Zone_Group_Name" {
  type = string
}