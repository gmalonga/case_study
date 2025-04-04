#!/bin/bash

# Script to initialize and deploy Terraform backend

set -e

echo "Initializing Terraform backend..."
cd backend
terraform init
echo "Terraform initialized"

# Run this command to get and copy the billing ID to use
echo "To get the billing ID, run:"
echo "gcloud beta billing accounts list"

echo "Deploying buckets for Terraform state..."
terraform apply
echo "Backends successfully deployed!"

# Display outputs
echo "Backend information:"
echo "Production state bucket: $(terraform output -raw terraform_state_bucket_prod)"
echo "Staging state bucket: $(terraform output -raw terraform_state_bucket_staging)" 