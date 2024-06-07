variable "vendor_configs" {
  type = map(string)
  default = {
    vendor1 = "./configs/vendor1.json",
    vendor2 = "./configs/vendor2.json"
  }
}

variable "project_id" {
  type        = string
  default = "itsme-1234"
}

variable "region" {
  type        = string
  default =  "us-central1"
}





