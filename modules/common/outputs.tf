output "vpc_network" {
  description = "The VPC network resource."
  value       = google_compute_network.vpc_network
}

output "public_subnets" {
  description = "The public subnets."
  value       = google_compute_subnetwork.public_subnet
}

output "private_subnets" {
  description = "The private subnets."
  value       = google_compute_subnetwork.private_subnet
}
