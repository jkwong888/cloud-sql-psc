variable "billing_account_id" {
  default = ""
}

variable "organization_id" {
  default = "" 
}

variable "parent_folder_id" {
  default = "" 
}

variable "service_project_id" {
  description = "The ID of the service project which hosts the project resources e.g. dev-55427"
}


variable "region" {
  default = "us-central1"
}

variable "subnets" {
  type = list(object({
    name=string,
    region=string,
    primary_range=string,
    secondary_range=map(any)
  }))
  default = []
}


