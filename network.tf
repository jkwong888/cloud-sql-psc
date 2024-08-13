resource "google_compute_network" "alloydb-net" {
  project      = google_project.service_project.project_id
  name = "alloydb-vpc"

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "alloydb-subnet" {
  project      = google_project.service_project.project_id
  name          = var.subnets[0].name
  ip_cidr_range = var.subnets[0].primary_range
  region        = var.region
  network       = google_compute_network.alloydb-net.id
}

resource "google_compute_router" "router" {
  project      = google_project.service_project.project_id
  name    = "alloydb-router"
  region  = google_compute_subnetwork.alloydb-subnet.region
  network = google_compute_network.alloydb-net.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  project      = google_project.service_project.project_id
  name                               = "alloydb-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


resource "google_compute_firewall" "allow-iap" {
  project      = google_project.service_project.project_id
  name    = "allow-iap"
  network = google_compute_network.alloydb-net.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "allow-internal" {
  project      = google_project.service_project.project_id
  name    = "allow-internal"
  network = google_compute_network.alloydb-net.name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["10.0.0.0/8"]
}

