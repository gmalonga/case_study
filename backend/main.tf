provider "google" {
  project = "webyn-case-study-prod"
  region  = "europe-west1"
}

# Production GCS bucket for Terraform states
resource "google_storage_bucket" "terraform_state_prod" {
  name          = "webyn-terraform-state-prod"
  location      = "EU"
  force_destroy = false
  
  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
}

provider "google" {
  alias   = "staging"
  project = "webyn-case-study-staging"
  region  = "europe-west1"
}

# Staging GCS bucket for Terraform states 
resource "google_storage_bucket" "terraform_state_staging" {
  provider      = google.staging
  name          = "webyn-terraform-state-staging"
  location      = "EU"
  force_destroy = false
  
  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
}

# Service account creation for Terraform operations
resource "google_service_account" "terraform_sa_prod" {
  account_id   = "terraform-runner-prod"
  display_name = "Terraform Runner Service Account - Production"
}

resource "google_service_account" "terraform_sa_staging" {
  provider     = google.staging
  account_id   = "terraform-runner-staging"
  display_name = "Terraform Runner Service Account - Staging"
}

# Limited access for the production project service account
resource "google_project_iam_member" "prod_storage_admin" {
  project = "webyn-case-study-prod"
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.terraform_sa_prod.email}"
}

resource "google_project_iam_member" "prod_run_admin" {
  project = "webyn-case-study-prod"
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.terraform_sa_prod.email}"
}

resource "google_project_iam_member" "prod_service_account_admin" {
  project = "webyn-case-study-prod"
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${google_service_account.terraform_sa_prod.email}"
}

# Limited access for the staging project service account
resource "google_project_iam_member" "staging_storage_admin" {
  provider = google.staging
  project  = "webyn-case-study-staging"
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.terraform_sa_staging.email}"
}

resource "google_project_iam_member" "staging_run_admin" {
  provider = google.staging
  project  = "webyn-case-study-staging"
  role     = "roles/run.admin"
  member   = "serviceAccount:${google_service_account.terraform_sa_staging.email}"
}

resource "google_project_iam_member" "staging_service_account_admin" {
  provider = google.staging
  project  = "webyn-case-study-staging"
  role     = "roles/iam.serviceAccountAdmin"
  member   = "serviceAccount:${google_service_account.terraform_sa_staging.email}"
}

# Outputs for future references
output "terraform_state_bucket_prod" {
  value = google_storage_bucket.terraform_state_prod.name
}

output "terraform_state_bucket_staging" {
  value = google_storage_bucket.terraform_state_staging.name
}

output "terraform_service_account_prod" {
  value = google_service_account.terraform_sa_prod.email
}

output "terraform_service_account_staging" {
  value = google_service_account.terraform_sa_staging.email
} 