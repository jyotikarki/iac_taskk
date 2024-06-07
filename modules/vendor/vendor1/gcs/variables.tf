variable "project_id" {
  type        = string
} 
variable "bucket_name" {
  type        = string

}

variable "region" {
  type        = string
}

variable "force_destroy" {
  type        = bool
  default     = false
}

variable "storage_class" {
  type        = string
  default     = "STANDARD"
}

variable "versioning_enabled" {
  type        = bool
  default     = false
}

variable "uniform_bucket_level_access" {
  type        = bool
  default     = true
}

variable pubsubname {
    type        = string
}

