provider "google" {
  project     = var.project_id
  region      = var.region
}

terraform {
  backend "gcs" {
    bucket  = "terraform-remote-backend-bucket"
    prefix  = "terraform/state"
  }
}

locals {
  vendor_data = { for vendor, path in var.vendor_configs : 
    vendor => jsondecode(file(path))
  }
  vendors = [for v in keys(local.vendor_data) : {
    name         = v
    project_id   = local.vendor_data[v].project_id
    region       = local.vendor_data[v].region
    dataset_id   = local.vendor_data[v].dataset_id
    pubsubname   = local.vendor_data[v].pubsubname
    functionname = local.vendor_data[v].functionname
    entry_point  = local.vendor_data[v].entry_point
    bucket_name  = local.vendor_data[v].bucket_name
  }]
}

# Common Module
module "common" {
  source = "./modules/common"
}

module "gcs_vendor1" {
  source      = "./modules/vendor/vendor1/gcs"
  project_id  = local.vendor_data["vendor1"].project_id
  region      = local.vendor_data["vendor1"].region
  bucket_name = local.vendor_data["vendor1"].bucket_name
  pubsubname    = local.vendor_data["vendor1"].pubsubname

  depends_on = [module.common,module.pubsub_vendor1]
}

module "bigquery_vendor1" {
  source     = "./modules/vendor/vendor1/bigquery"
  project_id = local.vendor_data["vendor1"].project_id
  region     = local.vendor_data["vendor1"].region
  dataset_id = local.vendor_data["vendor1"].dataset_id

  depends_on = [module.common]
}


module "cloud_function_vendor1" {
  source        = "./modules/vendor/vendor1/cloud_function"
  project_id    = local.vendor_data["vendor1"].project_id
  region        = local.vendor_data["vendor1"].region
  functionname  = local.vendor_data["vendor1"].functionname
  entry_point   = local.vendor_data["vendor1"].entry_point
  bucket_name   = local.vendor_data["vendor1"].bucket_name
  pubsubname    = local.vendor_data["vendor1"].pubsubname

  depends_on = [module.gcs_vendor1, module.pubsub_vendor1,module.bigquery_vendor1]
}

module "pubsub_vendor1" {
  source      = "./modules/vendor/vendor1/pubsub"
  project_id  = local.vendor_data["vendor1"].project_id
  pubsubname  = local.vendor_data["vendor1"].pubsubname
  region      = local.vendor_data["vendor1"].region

  depends_on = [module.common]
}

module "gcs_vendor2" {
  source      = "./modules/vendor/vendor2/gcs"
  project_id  = local.vendor_data["vendor2"].project_id
  region      = local.vendor_data["vendor2"].region
  bucket_name = local.vendor_data["vendor2"].bucket_name
  pubsubname    = local.vendor_data["vendor2"].pubsubname

  depends_on = [module.common,module.pubsub_vendor2]
}

module "bigquery_vendor2" {
  source     = "./modules/vendor/vendor2/bigquery"
  project_id = local.vendor_data["vendor2"].project_id
  region     = local.vendor_data["vendor2"].region
  dataset_id = local.vendor_data["vendor2"].dataset_id

  depends_on = [module.common]
}

module "cloud_function_vendor2" {
  source        = "./modules/vendor/vendor2/cloud_function"
  project_id    = local.vendor_data["vendor2"].project_id
  region        = local.vendor_data["vendor2"].region
  functionname  = local.vendor_data["vendor2"].functionname
  entry_point   = local.vendor_data["vendor2"].entry_point
  bucket_name   = local.vendor_data["vendor2"].bucket_name
  pubsubname    = local.vendor_data["vendor2"].pubsubname

  depends_on = [module.gcs_vendor2, module.bigquery_vendor2,module.pubsub_vendor2]
}

module "pubsub_vendor2" {
  source      = "./modules/vendor/vendor2/pubsub"
  project_id  = local.vendor_data["vendor2"].project_id
  pubsubname  = local.vendor_data["vendor2"].pubsubname
  region      = local.vendor_data["vendor2"].region

  depends_on = [module.common]
}