variable "name" {
  description = "Cloud Run service name"
  type        = string
}

variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "GCP region to deploy Cloud Run"
  type        = string
  default     = "europe-west1"
}

variable "image" {
  description = "Docker image to deploy"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8080
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "allow_public_access" {
  description = "Whether to allow public access to the service"
  type        = bool
  default     = false
}

variable "service_account_id" {
  description = "Service account ID to create for Cloud Run"
  type        = string
  default     = null
}

# Cloud Run service
resource "google_cloud_run_service" "service" {
  name     = var.name
  location = var.location
  project  = var.project

  template {
    spec {
      containers {
        image = var.image
        ports {
          container_port = var.container_port
        }
      }
      
      # If a service_account_id is provided, create and use this service account
      service_account_name = var.service_account_id != null ? google_service_account.cloud_run_sa[0].email : null
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = var.max_instances
        "autoscaling.knative.dev/minScale" = var.min_instances
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Conditional service account creation
resource "google_service_account" "cloud_run_sa" {
  count        = var.service_account_id != null ? 1 : 0
  project      = var.project
  account_id   = var.service_account_id
  display_name = "Service Account for ${var.name}"
}

# IAM policy to make the service public (conditional)
resource "google_cloud_run_service_iam_member" "public_access" {
  count    = var.allow_public_access ? 1 : 0
  service  = google_cloud_run_service.service.name
  location = google_cloud_run_service.service.location
  project  = var.project
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "url" {
  value = google_cloud_run_service.service.status[0].url
}

output "service_account_email" {
  value = var.service_account_id != null ? google_service_account.cloud_run_sa[0].email : null
} 