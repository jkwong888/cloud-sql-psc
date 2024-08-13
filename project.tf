data "google_folder" "parent_folder" {
    folder = var.parent_folder_id
}

resource "google_project" "service_project" {
  billing_account = var.billing_account_id
  project_id = format("%s-%s", var.service_project_id, random_id.random_suffix.hex)
  name = format("%s-%s", var.service_project_id, random_id.random_suffix.hex)
  auto_create_network = false
  folder_id = data.google_folder.parent_folder.id
}


resource "random_id" "random_suffix" {
  byte_length = 2
}


