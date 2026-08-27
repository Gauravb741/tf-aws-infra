#!/bin/bash
# =============================================================================
# Destroy Script
#
# IMPORTANT: This destroys ALL infrastructure in the specified environment.
# Use this to avoid AWS costs when not actively using the project.
#
# Usage:
#   ./scripts/destroy.sh dev
#   ./scripts/destroy.sh prod
# =============================================================================
set -euo pipefail

ENVIRONMENT="${1:-}"

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <environment>"
  echo "  Environments: dev, prod"
  exit 1
fi

TERRAFORM_DIR="terraform/environments/$ENVIRONMENT"

echo "============================================="
echo "  DESTROY: $ENVIRONMENT infrastructure"
echo "  $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "============================================="
echo ""
echo "  This will DESTROY all infrastructure in: $ENVIRONMENT"
echo "  Including: VPC, EC2, Security Groups, IAM roles, CloudWatch"
echo ""
echo "  The S3 state bucket and DynamoDB lock table will NOT be destroyed."
echo "  To remove them, delete manually via the AWS Console."
echo ""

read -r -p "Type the environment name '$ENVIRONMENT' to confirm: " CONFIRM

if [ "$CONFIRM" != "$ENVIRONMENT" ]; then
  echo "Destroy cancelled."
  exit 0
fi

echo ""
echo "[1/2] Terraform Init..."
terraform -chdir="$TERRAFORM_DIR" init

echo ""
echo "[2/2] Terraform Destroy..."
terraform -chdir="$TERRAFORM_DIR" destroy

echo ""
echo "============================================="
echo "  Infrastructure destroyed: $ENVIRONMENT"
echo "  AWS charges for this environment have stopped."
echo "============================================="