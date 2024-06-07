
resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public_subnet" {
  count                    = length(var.public_subnets)
  name                     = var.public_subnets[count.index].name
  ip_cidr_range            = var.public_subnets[count.index].cidr
  region                   = var.region
  network                  = google_compute_network.vpc_network.self_link
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "private_subnet" {
  count                    = length(var.private_subnets)
  name                     = var.private_subnets[count.index].name
  ip_cidr_range            = var.private_subnets[count.index].cidr
  region                   = var.region
  network                  = google_compute_network.vpc_network.self_link
  private_ip_google_access = false
}
