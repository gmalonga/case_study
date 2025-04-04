variable "name" {
  description = "GCS bucket name"
  type        = string
}

variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "GCS bucket location"
  type        = string
  default     = "EU"
}

variable "storage_class" {
  description = "Storage class for the bucket"
  type        = string
  default     = "STANDARD"
}

variable "versioning_enabled" {
  description = "Enable object versioning"
  type        = bool
  default     = false
}

variable "uniform_bucket_level_access" {
  description = "Enable uniform bucket-level access"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the bucket"
  type = list(object({
    action    = map(string)
    condition = map(string)
  }))
  default = []
}

# GCS bucket
resource "google_storage_bucket" "bucket" {
  name          = var.name
  project       = var.project
  location      = var.location
  storage_class = var.storage_class
  force_destroy = var.force_destroy
  
  versioning {
    enabled = var.versioning_enabled
  }
  
  uniform_bucket_level_access = var.uniform_bucket_level_access
  
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }
      condition {
        age                   = lookup(lifecycle_rule.value.condition, "age", null)
        created_before        = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state            = lookup(lifecycle_rule.value.condition, "with_state", null)
        matches_storage_class = try(lifecycle_rule.value.condition.matches_storage_class, null)
        num_newer_versions    = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
      }
    }
  }
}

output "name" {
  value = google_storage_bucket.bucket.name
}

output "url" {
  value = google_storage_bucket.bucket.url
} 