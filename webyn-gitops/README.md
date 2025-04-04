# Webyn GitOps

This repository contains the GitOps configuration for Webyn infrastructure and applications.

## Structure

```
webyn-gitops/
├── apps/                     # Deployed applications (Helm Charts)
│   ├── hello-world/          # Sample application (Helm Chart)
│   └── webyn-app/            # Main application (Helm Chart)
├── infrastructure/           # Shared infrastructure
│   └── argocd/               # ArgoCD configuration
└── environments/             # Environment-specific configurations
    ├── production/           # Production environment (Helm values.yaml)
    └── staging/              # Staging environment (Helm values.yaml)
```

## GitOps Concept

This architecture follows the GitOps principles where:
- Git repository is the single source of truth
- The desired system state is declared in code
- Changes are automatically applied by operators like ArgoCD
- Divergences between desired and actual state are automatically reconciled

## ArgoCD Setup

To install ArgoCD on your Kubernetes cluster:

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD using configuration file
kubectl apply -f infrastructure/argocd/install.yaml -n argocd

# Wait for all pods to be ready
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
```

Once installed, you can access the ArgoCD web interface:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

The interface will be available at http://localhost:8080

### Initial ArgoCD Configuration

Retrieve the initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Application Deployment

Applications are managed through ArgoCD ApplicationSet, which automatically creates an ArgoCD application for each Helm Chart in the `apps/` directory.

To install the ApplicationSet:

```bash
kubectl apply -f infrastructure/argocd/applications.yaml -n argocd
```

This triggers a process where:
1. ArgoCD monitors the Git repository
2. For each application found in the `apps/` folder, an ArgoCD application is created
3. The application is automatically deployed and synchronized with the source code

The current setup includes:
- A sample `hello-world` application (v0.1.0)
- The main `webyn-app` application

## Environments

Environments use Helm values.yaml files to customize application configurations.
To directly deploy an application to a specific environment (without using ArgoCD):

```bash
# Deploy webyn-app to production
helm upgrade --install webyn-app ./apps/webyn-app -f ./environments/production/values.yaml

# Deploy webyn-app to staging
helm upgrade --install webyn-app ./apps/webyn-app -f ./environments/staging/values.yaml
```

## Developer Workflow

1. Create a branch for your changes
2. Modify configurations or add new applications
3. Test locally with Helm if needed
4. Submit a Pull Request
5. After merging, ArgoCD will automatically deploy the changes

## Maintenance

To update ArgoCD:

```bash
kubectl apply -f infrastructure/argocd/install.yaml -n argocd
```

## ArgoCD Configuration Details

The ArgoCD setup in this repository:
- Uses Helm chart version 5.42.2
- Configures the server with LoadBalancer service type
- Disables Dex (external authentication)
- Enables ApplicationSet feature
- Implements automated sync with pruning and self-healing
- Automatically creates namespaces for each application 