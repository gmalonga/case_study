# GCP DevOps Foundation with Terraform

This project sets up a DevOps foundation on Google Cloud Platform using Terraform. It implements the requirements of the case study by managing:

## Key Features

1. **Two distinct GCP projects**: 
   - `webyn-case-study-staging` for the staging environment
   - `webyn-case-study-prod` for the production environment

2. **Remote GCS backend**:
   - Centralized bucket to store Terraform state files
   - Versioning enabled for state history and recovery

3. **Provisioned resources**:
   - Cloud Run applications
   - GCS storage buckets
   - Service accounts with appropriate permissions

4. **Well-scoped IAM roles**:
   - Read-only access for the staging environment
   - Admin roles for production deployment

## Project Structure

```
project/
├── backend/                  # Configuration for the Terraform state backend
├── environments/             # Environment-specific configurations
│   ├── staging/             # Configuration for the staging environment
│   └── production/          # Configuration for the production environment
├── modules/                  # Reusable Terraform modules
│   ├── cloud-run/           # Module for Cloud Run services
│   ├── gcs-bucket/          # Module for GCS buckets
│   └── iam/                 # Module for IAM management
├── deploy-backend.sh        # Backend deployment script
├── deploy-staging.sh        # Staging environment deployment script  
└── deploy-production.sh     # Production environment deployment script
```

## Deployment

1. Initialize the backend
```bash
./deploy-backend.sh
```

2. Deploy the staging environment resources
```bash
./deploy-staging.sh
```

3. Deploy the production environment resources
```bash
./deploy-production.sh
```

## Security Considerations

- Environments are completely isolated in separate GCP projects
- Service accounts follow the principle of least privilege
- GCS buckets have uniform bucket level access enabled
- IAM roles are well-scoped according to environment needs 