#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Linting YAML files in home-lab..."
echo ""

# Check if yamllint is installed
if ! command -v yamllint &> /dev/null; then
    echo -e "${YELLOW}⚠️  yamllint not found. Install with: pip install yamllint${NC}"
    echo ""
    exit 1
fi

# Check if kubeconform is installed
if ! command -v kubeconform &> /dev/null; then
    echo -e "${YELLOW}⚠️  kubeconform not found. Install with:${NC}"
    echo "   macOS: brew install kubeconform"
    echo "   Linux: Download from https://github.com/yannh/kubeconform/releases"
    echo ""
    exit 1
fi

# Run yamllint
echo -e "${GREEN}Running yamllint...${NC}"
if yamllint .; then
    echo -e "${GREEN}✅ yamllint passed!${NC}"
else
    echo -e "${RED}❌ yamllint found issues${NC}"
    exit 1
fi

echo ""

# Run kubeconform on apps directory
echo -e "${GREEN}Running kubeconform on apps/...${NC}"
if kubeconform -summary -output json -ignore-missing-schemas apps/; then
    echo -e "${GREEN}✅ kubeconform passed for apps/!${NC}"
else
    echo -e "${RED}❌ kubeconform found issues in apps/${NC}"
    exit 1
fi

echo ""

# Run kubeconform on argocd applications
echo -e "${GREEN}Running kubeconform on argocd/applications/...${NC}"
if kubeconform -summary -output json -ignore-missing-schemas argocd/applications/; then
    echo -e "${GREEN}✅ kubeconform passed for argocd/applications/!${NC}"
else
    echo -e "${RED}❌ kubeconform found issues in argocd/applications/${NC}"
    exit 1
fi

echo ""

# Run kubeconform on cluster manifests (excluding Helm values files)
echo -e "${GREEN}Running kubeconform on cluster/...${NC}"
if kubeconform -summary -output json -ignore-missing-schemas -ignore-filename-pattern 'ingress-nginx/' cluster/; then
    echo -e "${GREEN}✅ kubeconform passed for cluster/!${NC}"
else
    echo -e "${RED}❌ kubeconform found issues in cluster/${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 All linting checks passed!${NC}"
