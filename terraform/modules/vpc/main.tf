# =============================================================================
# VPC MODULE
#
# Creates a complete networking stack:
#   - VPC
#   - Public subnet  (EC2 instances with internet access)
#   - Private subnet (future use: RDS, ElastiCache, etc.)
#   - Internet Gateway
#   - Route tables and associations
#
# Why a custom VPC instead of the default VPC?
#   The default VPC is shared, not version-controlled, and cannot be
#   safely modified. A custom VPC gives full control over CIDR blocks,
#   routing and security, and can be destroyed cleanly with Terraform.
# =============================================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

# -----------------------------------------------------------------------------
# Public Subnet
# Resources here receive a public IP and can communicate directly with the
# internet via the Internet Gateway.
# -----------------------------------------------------------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-public-subnet"
    Tier = "public"
  })
}

# -----------------------------------------------------------------------------
# Private Subnet
# Resources here cannot be reached directly from the internet.
# A NAT Gateway would be required for outbound internet access from here,
# but is intentionally omitted to keep costs near zero for this demo.
# -----------------------------------------------------------------------------
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.aws_region}b"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-private-subnet"
    Tier = "private"
  })
}

# -----------------------------------------------------------------------------
# Internet Gateway
# Allows resources in public subnets to send and receive internet traffic.
# One IGW per VPC.
# -----------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-igw"
  })
}

# -----------------------------------------------------------------------------
# Public Route Table
# Routes all non-local traffic (0.0.0.0/0) through the Internet Gateway.
# -----------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-public-rt"
  })
}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# Private Route Table
# No internet route — private subnet is isolated.
# Extend this with a NAT Gateway route if private instances need outbound
# internet access (e.g. to download packages).
# -----------------------------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-private-rt"
  })
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}