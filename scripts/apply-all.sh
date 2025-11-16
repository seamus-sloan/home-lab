#!/bin/bash

# Script to apply all Kubernetes manifests in the apps/ directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APPS_DIR="$REPO_ROOT/apps"

echo "Applying all Kubernetes manifests from apps/ directory..."
echo "=================================================="

# Find all app directories
for app_dir in "$APPS_DIR"/*/ ; do
    if [ -d "$app_dir" ]; then
        app_name=$(basename "$app_dir")
        echo ""
        echo "📦 Applying $app_name..."
        
        # Apply all YAML files in the app directory
        if ls "$app_dir"*.yaml >/dev/null 2>&1; then
            kubectl apply -f "$app_dir"
        else
            echo "⚠️  No YAML files found in $app_name"
        fi
    fi
done

echo ""
echo "=================================================="
echo "✅ All applications applied successfully!"
