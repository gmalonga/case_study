terraform {
  required_version = ">= 1.0.0"
  
  # backend "gcs" {
  #   bucket = "webyn-terraform-state-prod"
  #   prefix = "env/production"
  # }
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "webyn-case-study-prod"
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
  
  project = "webyn-case-study-prod"
  service = each.value
  
  disable_on_destroy = false
}

# Service account for deployment - using IAM module
module "deployer_account" {
  source = "../../modules/iam"
  
  project_id                  = "webyn-case-study-prod"
  service_account_id          = "prod-deployer"
  service_account_display_name = "Production Deployment Account"
  project_roles               = [
    "roles/run.admin",
    "roles/storage.objectAdmin"
  ]
}

# Storage bucket for application data
module "prod_bucket" {
  source = "../../modules/gcs-bucket"
  
  name     = "webyn-prod-bucket-20250402"
  project  = "webyn-case-study-prod"
  location = "EU"
  
  versioning_enabled          = true
  uniform_bucket_level_access = true
  
  lifecycle_rules = [{
    action = {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition = {
      age = 90
    }
  }]
  
  depends_on = [google_project_service.apis]
}

# Service account with read-only access to the application
module "readonly_account" {
  source = "../../modules/iam"
  
  project_id                  = "webyn-case-study-prod" 
  service_account_id          = "prod-readonly"
  service_account_display_name = "Production Read-Only Account"
  project_roles               = [
    "roles/run.viewer"
  ]
  
  storage_bucket_roles = {
    (module.prod_bucket.name) = ["roles/storage.objectViewer"]
  }
}

# Cloud Run service
module "app" {
  source = "../../modules/cloud-run"
  
  name     = "webyn-prod-app"
  project  = "webyn-case-study-prod"
  location = "europe-west1"
  image    = "gcr.io/google-samples/hello-app:1.0"
  
  min_instances = 1
  allow_public_access = true
  
  depends_on = [google_project_service.apis]
}

output "prod_bucket_name" {
  value = module.prod_bucket.name
}

output "app_url" {
  value = module.app.url
} 