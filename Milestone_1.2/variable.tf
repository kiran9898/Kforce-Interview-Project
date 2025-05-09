variable "My_Subcription_ID" {
  type = string
}

variable "Location" {
  type = string
}
variable "Resource_Grp_Name" {
  type = string
}

variable "api_key" {
  description = "API Key for secure storage"
  type        = string
  sensitive   = true
}
