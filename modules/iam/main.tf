variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "service_account_id" {
  description = "Service account ID"
  type        = string
}

variable "service_account_display_name" {
  description = "Service account display name"
  type        = string
}

variable "project_roles" {
  description = "List of roles to assign to the service account in the project"
  type        = list(string)
  default     = []
}

variable "storage_bucket_roles" {
  description = "Map of buckets and their associated roles"
  type        = map(list(string))
  default     = {}
}

# Service account creation
resource "google_service_account" "service_account" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}

# Project-level role assignment
resource "google_project_iam_member" "project_roles" {
  for_each = toset(var.project_roles)
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

# Bucket-level role assignment
resource "google_storage_bucket_iam_member" "storage_roles" {
  for_each = {
    for pair in flatten([
      for bucket, roles in var.storage_bucket_roles : [
        for role in roles : {
          bucket = bucket
          role   = role
        }
      ]
    ]) : "${pair.bucket}-${pair.role}" => pair
  }
  
  bucket = each.value.bucket
  role   = each.value.role
  member = "serviceAccount:${google_service_account.service_account.email}"
}

output "service_account_email" {
  value = google_service_account.service_account.email
}

output "service_account_name" {
  value = google_service_account.service_account.name
} 