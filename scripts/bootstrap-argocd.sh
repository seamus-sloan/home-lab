#!/bin/bash
# Bootstrap script to set up ArgoCD with all applications
# This only needs to be run once - after that, ArgoCD manages itself!

set -e

echo "🚀 Bootstrapping ArgoCD applications..."
echo ""

# Apply the root app - it will create all other apps
echo "📦 Creating root-app (App of Apps)..."
kubectl apply -f argocd/applications/root-app.yaml

echo ""
echo "✅ Bootstrap complete!"
echo ""
echo "The root-app will now manage all your applications:"
echo "  - grafana"
echo "  - homepage"
echo "  - linkding"
echo ""
echo "Check status:"
echo "  kubectl get applications -n argocd"
echo ""
echo "Or visit the ArgoCD UI:"
echo "  http://argocd.sloan.com"
echo ""
