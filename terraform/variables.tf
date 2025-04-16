variable "subscription_id" {
  type        = string
  description = "Azure subscription ID used for deploying resources"
}

variable "client_id" {
  type        = string
  description = "Azure client ID for the service principal"
}

variable "client_secret" {
  type        = string
  description = "Azure client secret for the service principal"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID associated with the service principal"
}

variable "github_token" {
  type        = string
  description = "Personal access token for GitHub authentication"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "Azure region where resources will be deployed"
}
