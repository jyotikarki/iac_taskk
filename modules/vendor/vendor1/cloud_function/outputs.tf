output "cloud_function_name" {
  description = "The name of the deployed Cloud Function"
  value       = google_cloudfunctions_function.function.name
}
