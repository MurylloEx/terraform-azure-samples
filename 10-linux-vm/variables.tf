variable "azure_subscription_id" {
  type        = string
  description = "Identificador UUID da assinatura da Azure a ser usada."
}

variable "azure_tenant_id" {
  type        = string
  description = "Identificador UUID do diretório da Azure a ser usado."
}

variable "azure_client_id" {
  type        = string
  description = "Identificador UUID do cliente da Azure a ser usado."
}

variable "azure_client_secret" {
  type        = string
  description = "Valor do segredo do cliente da Azure."
}

variable "azure_region" {
  type        = string
  description = "Região da Azure a ser usada. Ex.: West Europe"
  default     = "West Europe"
}

variable "app_name" {
  type        = string
  description = "Nome da aplicação a ser implantada. Ex.: my-app"
}

variable "app_stage" {
  type        = string
  description = "Nome do estágio em que a aplicação se encontra. Ex.: dev, prod, stg"
  default     = "prod"
}
