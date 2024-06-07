variable "project_id" {
  type        = string
}

variable "region" {
  type        = string
}

variable "dataset_id" {
  type        = string
}

variable "dataset_description" {
  type        = string
  default     = "An example BigQuery dataset"
}

variable "default_table_expiration_ms" {
  type        = number
  default     = null
}
