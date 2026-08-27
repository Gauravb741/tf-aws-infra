# =============================================================================
# PROD ENVIRONMENT
#
# Same modules as dev, different variable values:
#   - Different CIDR space (10.1.x.x)
#   - Separate remote state key (prod/terraform.tfstate)
#   - Lower CPU alarm threshold (more sensitive in prod)
#   - Longer log retention
# =============================================================================

module "vpc" {
  source = "../../modules/vpc"

  project_name        = var.project_name
  environment         = var.environment
  aws_region          = var.aws_region
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  tags                = local.common_tags
}

module "security" {
  source = "../../modules/security"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  application_port = var.application_port
  allowed_ssh_cidr = var.allowed_ssh_cidr
  tags             = local.common_tags
}

module "ec2" {
  source = "../../modules/ec2"

  project_name      = var.project_name
  environment       = var.environment
  instance_type     = var.instance_type
  subnet_id         = module.vpc.public_subnet_id
  security_group_id = module.security.ec2_security_group_id
  key_pair_name     = var.key_pair_name
  application_port  = var.application_port
  docker_image      = var.docker_image
  app_version       = var.app_version
  tags              = local.common_tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name        = var.project_name
  environment         = var.environment
  aws_region          = var.aws_region
  instance_id         = module.ec2.instance_id
  cpu_alarm_threshold = var.cpu_alarm_threshold
  log_retention_days  = var.log_retention_days
  tags                = local.common_tags
}