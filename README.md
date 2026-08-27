# Architecture Documentation

## Overview

This project implements a complete DevOps workflow for deploying a containerised
web application to AWS using Infrastructure as Code (Terraform) and an automated
CI/CD pipeline (GitHub Actions).

## Components

### 1. Application Layer

A Python Flask web application running inside a Docker container on an EC2 instance.

**Why Docker?**
- Consistent environment from development to production
- Application and its dependencies are packaged together
- Easy rollback by deploying a previous image tag
- Container restart policy handles application crashes automatically

### 2. Infrastructure Layer (Terraform)

All AWS infrastructure is defined as Terraform code, organized into reusable modules.

**Why Terraform?**
- Infrastructure is version-controlled alongside the application
- Changes are reviewed before being applied (plan → apply workflow)
- Modules prevent code duplication between environments
- State management prevents drift and conflicts

**Module breakdown:**

| Module       | Responsibility                                    |
|-------------|---------------------------------------------------|
| `vpc`       | VPC, subnets, Internet Gateway, route tables       |
| `security`  | Security groups (firewall rules)                   |
| `ec2`       | EC2 instance, IAM role, dynamic AMI, user data     |
| `monitoring`| CloudWatch alarms, dashboard, log group            |

### 3. CI/CD Layer (GitHub Actions)

Three workflows manage the full lifecycle:

| Workflow             | Trigger              | Purpose                               |
|---------------------|----------------------|---------------------------------------|
| `terraform-check`   | Every push / PR      | Fmt check, validate, security scan    |
| `terraform-plan`    | Pull requests        | Show infrastructure diff              |
| `terraform-apply`   | Push to main         | Build Docker, deploy dev, deploy prod |

### 4. Security Layer

| Layer       | Mechanism                                                   |
|-------------|-------------------------------------------------------------|
| AWS Auth    | OIDC — no long-lived keys stored                            |
| EC2 Access  | IAM role with least privilege policies                      |
| Network     | Security groups restricting inbound access                  |
| State       | Encrypted S3 bucket, DynamoDB locking                       |
| Code        | Checkov + Trivy scanning in CI pipeline                     |
| Secrets     | GitHub Secrets/Variables — never in repository              |

## Network Architecture

