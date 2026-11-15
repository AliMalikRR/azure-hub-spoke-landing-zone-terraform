variable "region" {
  description = "The region resource deployments are restricted to, due to company policy"
  type        = string
}

variable "hub_address_space" {
  description = "Address space for the Hub virtual network"
  type        = list(string)
}

variable "bastion_subnet" {
  description = "Azure bastion subnet"
  type        = list(string)
}

variable "private_endpoint_subnet" {
  description = "Private endpoint subnet"
  type        = list(string)
}

variable "app_address_space" {
  description = "Address space for the App VNet"
  type        = list(string)
}

variable "management_address_space" {
  description = "Management VNet address space"
  type        = list(string)
}

variable "app_subnet" {
  description = "Application subnet"
  type        = list(string)
}

variable "management_subnet" {
  description = "Management subnet"
  type        = list(string)
}

variable "appsrv_winadmin_username" {
  description = "Local admin username for application vm"
  sensitive   = true
}

variable "appsrv_winadmin_password" {
  description = "Application VM local admin password"
  type        = string
  sensitive   = true
}