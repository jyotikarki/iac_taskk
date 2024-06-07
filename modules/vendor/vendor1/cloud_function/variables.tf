variable "project_id" {
  type        = string
}

variable "region" {
  type        = string
}


variable "pubsubname" {
  type        = string

}

variable "entry_point" {
  type        = string
}


variable "functionname" {
  type        = string
}

variable "bucket_name" {
  type        = string
}

variable "source_archive_object" {
  type        = string
  default = "function.zip"
}





