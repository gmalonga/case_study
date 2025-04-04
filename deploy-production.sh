#!/bin/bash

# Script to deploy the production environment

set -e

echo "Initializing Terraform for production environment..."
cd environments/production
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

echo "Checking Terraform pln..."
terraform plan

echo "WARNING: You are about to deploy the PRODUCTION environment."
echo "Do you want to apply these changes? (production/no)"
read response

if [ "$response" == "production" ]; then
    echo "Deploying production environment resources..."
    terraform apply
    
    echo "Production environment successfully deployed!"
    
    # Display outputs
    echo "Production environment information:"
    terraform output
else
    echo "Deployment cancelled."
fi 