#!/bin/bash
# =============================================================================
# Deploy Script
#
# Deploys the application to a specified environment.
#
# Usage:
#   ./scripts/deploy.sh dev
#   ./scripts/deploy.sh prod
# =============================================================================
set -euo pipefail

ENVIRONMENT="${1:-}"

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <environment>"
  echo "  Environments: dev, prod"
  exit 1
fi

if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; then
  echo "Error: environment must be 'dev' or 'prod'"
  exit 1
fi

TERRAFORM_DIR="terraform/environments/$ENVIRONMENT"

echo "============================================="
echo "  Deploying to: $ENVIRONMENT"
echo "  Directory:    $TERRAFORM_DIR"
echo "  $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "============================================="

if [ "$ENVIRONMENT" = "prod" ]; then
  echo ""
  echo "WARNING: You are about to deploy to PRODUCTION."
  echo "         This will modify real infrastructure."
  echo ""
  read -r -p "Type 'yes' to confirm: " CONFIRM
  if [ "$CONFIRM" != "yes" ]; then
    echo "Deployment cancelled."
    exit 0
  fi
fi

echo ""
echo "[1/4] Terraform Init..."
terraform -chdir="$TERRAFORM_DIR" init

echo ""
echo "[2/4] Terraform Validate..."
terraform -chdir="$TERRAFORM_DIR" validate

echo ""
echo "[3/4] Terraform Plan..."
terraform -chdir="$TERRAFORM_DIR" plan -out=tfplan.out

echo ""
echo "[4/4] Terraform Apply..."
terraform -chdir="$TERRAFORM_DIR" apply tfplan.out

echo ""
echo "============================================="
echo "  Deployment complete: $ENVIRONMENT"
echo "============================================="
echo ""

# Print outputs
terraform -chdir="$TERRAFORM_DIR" output