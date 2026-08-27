#!/bin/bash
# =============================================================================
# Setup Script
#
# Verifies all required tools are installed and helps the user configure
# the project for their environment.
#
# Usage: ./scripts/setup.sh
# =============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No colour

print_header() {
  echo ""
  echo -e "${BLUE}=============================================${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}=============================================${NC}"
}

print_ok() {
  echo -e "  ${GREEN}✓${NC} $1"
}

print_warn() {
  echo -e "  ${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "  ${RED}✗${NC} $1"
}

check_command() {
  local cmd=$1
  local version_flag=${2:---version}
  
  if command -v "$cmd" &>/dev/null; then
    VERSION=$("$cmd" $version_flag 2>&1 | head -1)
    print_ok "$cmd: $VERSION"
    return 0
  else
    print_error "$cmd: NOT FOUND"
    return 1
  fi
}

print_header "Tool Version Check"

MISSING=0

check_command git || MISSING=$((MISSING + 1))
check_command terraform version || MISSING=$((MISSING + 1))
check_command aws --version || MISSING=$((MISSING + 1))
check_command docker --version || MISSING=$((MISSING + 1))
check_command python3 --version || MISSING=$((MISSING + 1))

if [ $MISSING -gt 0 ]; then
  echo ""
  print_error "$MISSING required tool(s) not found."
  echo ""
  echo "Install missing tools:"
  echo "  Terraform: https://developer.hashicorp.com/terraform/install"
  echo "  AWS CLI:   https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
  echo "  Docker:    https://docs.docker.com/get-docker/"
  exit 1
fi

print_header "AWS Configuration Check"

if aws sts get-caller-identity &>/dev/null; then
  IDENTITY=$(aws sts get-caller-identity --output json)
  ACCOUNT=$(echo "$IDENTITY" | python3 -c "import json,sys; print(json.load(sys.stdin)['Account'])")
  USER=$(echo "$IDENTITY" | python3 -c "import json,sys; print(json.load(sys.stdin)['Arn'])")
  print_ok "AWS authenticated"
  echo "    Account: $ACCOUNT"
  echo "    ARN:     $USER"
else
  print_warn "AWS not configured. Run: aws configure"
fi

print_header "Project Configuration"

echo ""
echo "Next steps:"
echo ""
echo "  1. Bootstrap remote state:"
echo "     ./terraform/scripts/bootstrap-state.sh"
echo ""
echo "  2. Update backend config in versions.tf:"
echo "     terraform/environments/dev/versions.tf"
echo "     terraform/environments/prod/versions.tf"
echo ""
echo "  3. Create terraform.tfvars:"
echo "     cp terraform/environments/dev/terraform.tfvars.example terraform/environments/dev/terraform.tfvars"
echo "     cp terraform/environments/prod/terraform.tfvars.example terraform/environments/prod/terraform.tfvars"
echo "     # Edit both files with your values"
echo ""
echo "  4. Deploy dev:"
echo "     cd terraform/environments/dev"
echo "     terraform init"
echo "     terraform plan"
echo "     terraform apply"
echo ""
echo "  See docs/deployment.md for the complete guide."
echo ""