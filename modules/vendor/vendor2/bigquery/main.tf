
resource "google_bigquery_dataset" "example_dataset" {
  dataset_id                  = var.dataset_id
  location                    = var.region
  default_table_expiration_ms = var.default_table_expiration_ms
  description                 = var.dataset_description
}

