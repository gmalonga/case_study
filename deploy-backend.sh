#!/bin/bash

# Script to initialize and deploy Terraform backend

set -e

echo "Initializing Terraform backend..."
cd backend
terraform init
echo "Terraform initialized"

echo "Deploying buckets for Terraform state..."
terraform apply
echo "Backends successfully deployed!"

# Display outputs
echo "Backend information:"
echo "Production state bucket: $(terraform output -raw terraform_state_bucket_prod)"
echo "Staging state bucket: $(terraform output -raw terraform_state_bucket_staging)" 