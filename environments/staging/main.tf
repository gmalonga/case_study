terraform {
  required_version = ">= 1.0.0"
  
  # GCS backend disabled due to access issues
  # backend "gcs" {
  #   bucket = "webyn-terraform-state-staging"
  #   prefix = "env/staging"
  # }
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "webyn-case-study-staging"
  region  = "europe-west1"
}

# Enabling required APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com",
    "run.googleapis.com",
    "compute.googleapis.com"
  ])
  
  project = "webyn-case-study-staging"
  service = each.value
  
  disable_on_destroy = false
}

# Service account with read-only access - well scoped
module "readonly_account" {
  source = "../../modules/iam"
  
  project_id                  = "webyn-case-study-staging"
  service_account_id          = "staging-readonly"
  service_account_display_name = "Staging Read-Only Account"
  project_roles               = [
    "roles/viewer"
  ]
}

# Storage bucket for staging data
module "staging_bucket" {
  source = "../../modules/gcs-bucket"
  
  name     = "webyn-staging-bucket-20250402"
  project  = "webyn-case-study-staging"
  location = "EU"
  
  versioning_enabled          = true
  uniform_bucket_level_access = true
  
  depends_on = [google_project_service.apis]
}

# Service account with limited access to the bucket
module "bucket_editor" {
  source = "../../modules/iam"
  
  project_id                  = "webyn-case-study-staging"
  service_account_id          = "staging-bucket-editor"
  service_account_display_name = "Staging Bucket Editor"
  
  # No project-level roles
  project_roles = []
  
  # Access only to the specific bucket with a well-scoped role
  storage_bucket_roles = {
    (module.staging_bucket.name) = ["roles/storage.objectAdmin"]
  }
}

# Cloud Run service
module "app" {
  source = "../../modules/cloud-run"
  
  name     = "webyn-staging-app"
  project  = "webyn-case-study-staging"
  location = "europe-west1"
  image    = "gcr.io/google-samples/hello-app:1.0"
  
  allow_public_access = true
  
  depends_on = [google_project_service.apis]
}

output "staging_bucket_name" {
  value = module.staging_bucket.name
}

output "app_url" {
  value = module.app.url
}

output "bucket_editor_email" {
  value = module.bucket_editor.service_account_email
  description = "Email of the service account with access limited to the staging bucket only"
} 