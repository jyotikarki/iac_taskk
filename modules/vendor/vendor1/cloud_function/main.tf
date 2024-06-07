resource "google_cloudfunctions_function" "function" {
  name        = var.functionname
  description = "Triggered by GCS when a CSV file is uploaded"
  runtime     = "python39"

  available_memory_mb   = 256
  source_archive_bucket = var.bucket_name
  source_archive_object = var.source_archive_object
  entry_point           = var.entry_point

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = var.pubsubname
  }

  environment_variables = {
    PUBSUB_TOPIC = var.pubsubname
  }

}

