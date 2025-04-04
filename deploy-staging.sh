#!/bin/bash

# Script to deploy the staging environment

set -e

echo "Initializing Terraform for staging environment..."
cd environments/staging
terraform init -reconfigure
echo "Terraform initialized"

# Check if terraform.tfvars file exists
if [ ! -f terraform.tfvars ]; then
    echo "terraform.tfvars file does not exist."
    echo "Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "Please edit the terraform.tfvars file with your values before continuing."
    exit 1
fi

echo "Checking Terraform plan..."
terraform plan

echo "Do you want to apply these changes? (yes/no)"
read response

if [ "$response" == "yes" ]; then
    echo "Deploying staging environment resources..."
    terraform apply
    
    echo "Staging environment successfully deployed!"
    
    # Display outputs
    echo "Staging environment information:"
    terraform output
else
    echo "Deployment cancelled."
fi 