resource "google_sql_database_instance" "main" {
  project      = google_project.service_project.project_id
  name             = "psc-enabled-main-instance"
  database_version = "POSTGRES_15"
  region = var.region
  settings {
    tier    = "db-f1-micro"
    ip_configuration {
      psc_config {
        psc_enabled = true
        allowed_consumer_projects = [google_project.service_project.project_id]
      }
      ipv4_enabled = false
    }
    backup_configuration {
      enabled = true
      point_in_time_recovery_enabled = true
    }
    availability_type = "REGIONAL"
  }

  deletion_protection = false
}

resource "google_sql_database" "database" {
  project      = google_project.service_project.project_id
  name     = "db"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "users" {
  project  = google_project.service_project.project_id
  name     = "user"
  instance = google_sql_database_instance.main.name
  password = "changeme"
}

resource "google_compute_address" "cloud_sql_ilb_address" {
  depends_on = [ 
    google_compute_network.alloydb-net,
  ]

  project      = google_project.service_project.project_id
  name   = "cloud-sql-address"
  region = var.region

  subnetwork   = google_compute_subnetwork.alloydb-subnet.id
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "cloud_sql_ilb_fwrule" {
  project      = google_project.service_project.project_id
  name   = "cloud-sql-ilb"
  region = var.region

  target                = google_sql_database_instance.main.psc_service_attachment_link 
  load_balancing_scheme = "" # need to override EXTERNAL default when target is a service attachment
  network               = google_compute_network.alloydb-net.name
  ip_address            = google_compute_address.cloud_sql_ilb_address.id
}