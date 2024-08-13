resource "google_compute_instance" "default" {
  project      = google_project.service_project.project_id
  name         = "alloydb-client"
  machine_type = "e2-standard-2"
  zone         = "us-central1-a"

  deletion_protection = false

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }


  network_interface {
    subnetwork = google_compute_subnetwork.alloydb-subnet.self_link
  }

  scheduling {
    preemptible = true
    provisioning_model = "SPOT"
    automatic_restart = false
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    scopes = ["cloud-platform"]
  }
}