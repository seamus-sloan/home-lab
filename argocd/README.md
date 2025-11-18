# ArgoCD Helm Chart

A simple wrapper chart for deploying ArgoCD in your home lab.

## What is this?

This is a Helm chart that depends on the official ArgoCD chart. Instead of using the upstream chart directly, we wrap it so everything lives in Git and you can easily customize and version control your deployment.

## Structure

```
argocd/
├── Chart.yaml       # Defines dependency on official argo-cd chart
├── values.yaml      # Your custom configuration
└── README.md        # This file
```

## Installation

### 1. Download dependencies

First time setup - download the upstream ArgoCD chart:

```bash
cd argocd
helm dependency update
```

**Note for Helm v4 users**: There's a known issue with compressed chart dependencies. After running `helm dependency update`, extract the chart:

```bash
cd charts
tar -xzf argo-cd-*.tgz
cd ../..
```

This creates a `charts/` directory with the ArgoCD chart.

### 2. Install ArgoCD

From the repository root:

```bash
helm install argocd ./argocd --namespace argocd --create-namespace
```

### 3. Get admin password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
echo
```

### 4. Access ArgoCD

Your ingress is configured for `argocd.sloan.com`. Make sure your DNS points to your cluster (192.168.1.99).

Or use port-forward:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

Then visit: http://localhost:8080

## Upgrading

### Update ArgoCD version

Edit `Chart.yaml` and change the version:

```yaml
dependencies:
  - name: argo-cd
    version: "7.8.0"  # Update this
    repository: https://argoproj.github.io/argo-helm
```

Then:

```bash
cd argocd
helm dependency update
helm upgrade argocd ./argocd --namespace argocd
```

### Update configuration

Edit `values.yaml` with your changes, then:

```bash
helm upgrade argocd ./argocd --namespace argocd
```

## Configuration

All configuration goes in `values.yaml` under the `argo-cd:` key since it's a dependency.

Example - change hostname:

```yaml
argo-cd:
  server:
    ingress:
      hostname: argocd.yourdomain.com
```

See available options: https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd

## Uninstalling

```bash
helm uninstall argocd --namespace argocd
kubectl delete namespace argocd
```

## Tips for Learning

- **Helm dependencies**: The `Chart.yaml` file tells Helm to download the official ArgoCD chart
- **Values override**: Your `values.yaml` overrides the defaults from the upstream chart
- **helm dependency update**: Downloads/updates the charts listed in dependencies
- **charts/ directory**: Auto-generated, don't commit it (add to .gitignore)

## Next Steps

Once ArgoCD is running, you can use it to manage your other apps (grafana, homepage, linkding) by creating Application manifests. Check the ArgoCD docs for the "App of Apps" pattern!
