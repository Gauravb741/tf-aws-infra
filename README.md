# ☁️ Terraform AWS Infrastructure & DevOps Platform

A complete **Infrastructure as Code (IaC) and DevOps project** that provisions AWS infrastructure using Terraform and deploys a containerized Flask application to Amazon EC2 through an automated GitHub Actions pipeline.

The project combines:

* Terraform
* AWS
* EC2
* VPC
* IAM
* Security Groups
* CloudWatch
* Docker
* GitHub Actions
* OIDC authentication
* Checkov
* Trivy
* Python Flask

The infrastructure is designed using reusable Terraform modules and separate **development and production environments**.

---

# 📌 Overview

The project automates the complete infrastructure and application deployment lifecycle.

Instead of manually creating AWS resources and deploying the application, Terraform manages the infrastructure while GitHub Actions handles validation, planning, image building, and deployment.

```text
Developer
    │
    │ git push / Pull Request
    ▼
GitHub Repository
    │
    ▼
GitHub Actions
    │
    ├── Terraform Format
    ├── Terraform Validate
    ├── Security Scan
    └── Terraform Plan
    │
    ▼
Terraform
    │
    ├── VPC
    ├── Subnets
    ├── Security Groups
    ├── EC2
    ├── IAM
    └── CloudWatch
    │
    ▼
AWS Infrastructure
    │
    ▼
EC2 Instance
    │
    ├── Amazon Linux 2023
    ├── Docker
    └── Flask Application
    │
    ▼
Application
```

---

# 🎯 Project Objective

The main objective is to demonstrate how modern DevOps practices can be used to provision and manage AWS infrastructure using **Infrastructure as Code**.

The project focuses on:

* Infrastructure automation
* Terraform modules
* AWS networking
* EC2 provisioning
* IAM-based authentication
* Docker deployment
* CI/CD automation
* Infrastructure validation
* Security scanning
* Environment separation
* CloudWatch monitoring
* Terraform state management

---

# 🛠️ Technology Stack

| Technology        | Purpose                        |
| ----------------- | ------------------------------ |
| Terraform         | Infrastructure as Code         |
| AWS               | Cloud infrastructure           |
| EC2               | Application compute            |
| VPC               | Network isolation              |
| Security Groups   | Network firewall               |
| IAM               | AWS permissions                |
| CloudWatch        | Monitoring and logging         |
| Docker            | Application containerization   |
| Python            | Application runtime            |
| Flask             | Web application                |
| GitHub Actions    | CI/CD automation               |
| OIDC              | AWS authentication from GitHub |
| Checkov           | Terraform security scanning    |
| Trivy             | Container security scanning    |
| Amazon Linux 2023 | EC2 operating system           |

---

# 🏗️ Architecture

```text
                         ┌───────────────────────┐
                         │       Developer       │
                         │                       │
                         │      git push         │
                         └───────────┬───────────┘
                                     │
                                     ▼
                         ┌───────────────────────┐
                         │        GitHub         │
                         │     Repository        │
                         └───────────┬───────────┘
                                     │
                                     ▼
                         ┌───────────────────────┐
                         │    GitHub Actions     │
                         │                       │
                         │ Terraform Check       │
                         │ Terraform Plan        │
                         │ Terraform Apply       │
                         └───────────┬───────────┘
                                     │
                                     ▼
                         ┌───────────────────────┐
                         │       Terraform       │
                         │                       │
                         │   Infrastructure     │
                         │   as Code            │
                         └───────────┬───────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    ▼                ▼                ▼
              ┌──────────┐    ┌─────────────┐  ┌──────────────┐
              │   VPC    │    │ Security    │  │  Monitoring  │
              │          │    │   Groups    │  │  CloudWatch  │
              └────┬─────┘    └──────┬──────┘  └──────┬───────┘
                   │                 │                 │
                   └─────────────────┼─────────────────┘
                                     │
                                     ▼
                            ┌──────────────────┐
                            │       EC2        │
                            │                  │
                            │ Amazon Linux     │
                            │ Docker           │
                            │ IAM Role         │
                            └────────┬─────────┘
                                     │
                                     ▼
                            ┌──────────────────┐
                            │ Docker Container │
                            │                  │
                            │ Flask App        │
                            │ Gunicorn         │
                            └──────────────────┘
```

---

# 📁 Project Structure

```text
tf-aws-infra/
│
├── .github/
│   └── workflows/
│       ├── terraform-check.yml
│       ├── terraform-plan.yml
│       └── terraform-apply.yml
│
├── app/
│   ├── src/
│   │   └── app.py
│   ├── Dockerfile
│   └── requirements.txt
│
├── docs/
│   ├── architecture.md
│   └── deployment.md
│
├── terraform/
│   │
│   ├── environments/
│   │   ├── dev/
│   │   └── prod/
│   │
│   ├── modules/
│   │   ├── vpc/
│   │   ├── security/
│   │   ├── ec2/
│   │   └── monitoring/
│   │
│   └── scripts/
│       ├── bootstrap-state.sh
│       ├── deploy.sh
│       ├── destroy.sh
│       └── setup.sh
│
├── .gitignore
└── README.md
```

---

# 🧩 Terraform Architecture

Terraform is organized into two major concepts:

```text
Reusable Modules
       │
       ▼
Environment Configuration
       │
       ├── Development
       └── Production
```

The reusable modules are:

```text
terraform/modules/

├── vpc/
├── security/
├── ec2/
└── monitoring/
```

The environments are:

```text
terraform/environments/

├── dev/
└── prod/
```

This allows the same infrastructure components to be reused with different environment-specific values.

---

# 🌐 VPC Module

The VPC module creates the networking infrastructure.

It includes:

* Custom VPC
* Public subnet
* Private subnet
* Internet Gateway
* Public route table
* Private route table
* Route table associations

The project intentionally uses a custom VPC rather than the AWS default VPC so that networking configuration remains completely managed by Terraform.

Architecture:

```text
                    VPC
                     │
          ┌──────────┴──────────┐
          │                     │
          ▼                     ▼
   Public Subnet         Private Subnet
          │                     │
          │                     │
          ▼                     ▼
 Internet Gateway          Isolated
          │
          ▼
       Internet
```

The public subnet is configured to automatically assign public IP addresses.

The private subnet does not have a direct internet route.

A NAT Gateway is intentionally not provisioned in the current configuration to keep the demonstration infrastructure inexpensive.

---

# 🔐 Security Group

The security module creates an EC2 security group.

The inbound rules include:

### SSH

Port:

```text
22
```

SSH access is restricted using the configured:

```text
allowed_ssh_cidr
```

This allows SSH access to be limited to a specific IP or CIDR instead of exposing SSH to the entire internet.

### Application

The configured application port is exposed to:

```text
0.0.0.0/0
```

### Outbound

Outbound traffic is allowed for:

* Package installation
* Docker image downloads
* AWS APIs
* CloudWatch
* Other required external services

The security group uses `create_before_destroy` to reduce disruption during replacement.

---

# 🖥️ EC2 Module

The EC2 module provisions the application server.

The instance includes:

```text
Amazon Linux 2023
       │
       ├── IAM Role
       ├── Security Group
       ├── Encrypted EBS Volume
       ├── Docker
       └── Flask Application
```

---

# 🔄 Dynamic AMI Selection

Instead of hardcoding an AMI ID, the project dynamically searches for the latest Amazon Linux 2023 AMI.

Terraform filters for:

```text
Amazon Linux 2023
x86_64
HVM
Available
```

This prevents the configuration from becoming dependent on an outdated AMI ID.

---

# 🔑 IAM Role

The EC2 instance receives an IAM role instead of storing AWS access keys on the server.

The role provides access for:

* CloudWatch
* CloudWatch Logs
* Systems Manager

Systems Manager access is provided through:

```text
AmazonSSMManagedInstanceCore
```

This allows Session Manager to be used as an alternative to traditional SSH access.

---

# 💾 EBS Storage

The EC2 instance uses an encrypted `gp3` root volume.

Configuration includes:

```text
Volume Type: gp3
Size: 20 GB
Encryption: Enabled
Delete on termination: Enabled
```

This ensures the root disk is encrypted while avoiding orphaned storage after instance termination.

---

# 🐳 Docker Deployment

Docker is installed automatically through the EC2 user-data script.

The bootstrap process:

```text
EC2 starts
   │
   ▼
Amazon Linux update
   │
   ▼
Install Docker
   │
   ▼
Start Docker
   │
   ▼
Enable Docker on boot
   │
   ▼
Pull application image
   │
   ▼
Start container
   │
   ▼
Run health check
   │
   ▼
Application ready
```

The container uses:

```bash
docker run -d \
  --name devops-app \
  --restart unless-stopped \
  -p <application-port>:5000 \
  <docker-image>
```

The container is configured to restart automatically if it crashes or if the Docker service restarts.

---

# 🐍 Flask Application

The project contains a lightweight Flask application.

The application is designed primarily to verify that the infrastructure and deployment pipeline are working correctly.

It exposes:

```text
/
 /health
```

---

# `/`

Returns application information.

Example:

```json
{
  "application": "Terraform AWS DevOps Platform",
  "environment": "production",
  "version": "1.0.0",
  "status": "running",
  "hostname": "...",
  "uptime_seconds": 123.45,
  "timestamp": "..."
}
```

The response includes the hostname and uptime, making it useful for verifying which EC2/container instance is serving the request.

---

# `/health`

Health endpoint:

```text
GET /health
```

Returns:

```json
{
  "status": "healthy",
  "version": "1.0.0",
  "environment": "production",
  "uptime_seconds": 123.45,
  "timestamp": "..."
}
```

This endpoint is used by the Docker health check and can also be used by external monitoring systems.

---

# 🐳 Dockerfile

The application uses a multi-stage Docker build.

```text
Builder Stage
      │
      ├── Python 3.12 Slim
      ├── Install dependencies
      │
      ▼
Production Stage
      │
      ├── Python 3.12 Slim
      ├── Copy dependencies
      ├── Copy application
      ├── Non-root user
      ├── Health check
      └── Gunicorn
```

The final container runs as:

```text
appuser
UID: 1001
```

rather than root.

The production server uses Gunicorn:

```text
0.0.0.0:5000
```

with two workers.

---

# ❤️ Docker Health Check

The container periodically checks:

```text
http://localhost:5000/health
```

Configuration:

```text
Interval: 30 seconds
Timeout: 10 seconds
Start Period: 15 seconds
Retries: 3
```

If the application stops responding correctly, Docker marks the container unhealthy.

---

# 📊 Monitoring Module

The monitoring module uses AWS CloudWatch.

It provides:

* CloudWatch Log Group
* CPU utilization alarm
* EC2 status check alarm
* CloudWatch dashboard

---

# 📈 CPU Alarm

The CPU alarm monitors:

```text
AWS/EC2
CPUUtilization
```

The threshold is configurable through Terraform variables.

The alarm evaluates CPU utilization across two consecutive five-minute periods.

```text
5 min
  +
5 min
  =
10 min evaluation
```

This reduces the chance of triggering an alarm from a very short CPU spike.

---

# 🚨 EC2 Status Check Alarm

The project also monitors:

```text
StatusCheckFailed
```

This helps detect EC2 system or instance-level failures.

The monitoring covers:

```text
System Status
Instance Status
```

---

# 📋 CloudWatch Dashboard

A CloudWatch dashboard is automatically created for each environment.

The dashboard includes:

```text
CPU Utilization
       +
EC2 Status Checks
```

This gives a quick overview of the EC2 instance health.

---

# 🗂️ Environment Separation

The Terraform configuration contains two environments:

```text
terraform/environments/

├── dev/
└── prod/
```

Both environments use the same Terraform modules but provide different values.

---

# 🧪 Development Environment

The development environment uses the same modules as production but can use:

* Smaller EC2 instance
* Different CIDR ranges
* Separate state configuration
* Separate CloudWatch resources
* Different alarm threshold
* Different application version

The environment wires together:

```text
VPC
 │
 ├── Security
 │
 ├── EC2
 │
 └── Monitoring
```

---

# 🚀 Production Environment

The production environment uses the same modules while providing production-specific values.

The repository configuration documents:

```text
CIDR space: 10.1.x.x
Separate state key
More sensitive CPU alarm
Longer log retention
```

---

# 🧱 Terraform Modules

## VPC

```text
terraform/modules/vpc
```

Creates:

```text
VPC
Public Subnet
Private Subnet
Internet Gateway
Route Tables
Route Associations
```

---

## Security

```text
terraform/modules/security
```

Creates:

```text
EC2 Security Group
SSH Rule
Application Rule
Outbound Rule
```

---

## EC2

```text
terraform/modules/ec2
```

Creates:

```text
AMI Lookup
IAM Role
IAM Policies
Instance Profile
EC2 Instance
Encrypted EBS
User Data
```

---

## Monitoring

```text
terraform/modules/monitoring
```

Creates:

```text
CloudWatch Log Group
CPU Alarm
Status Check Alarm
CloudWatch Dashboard
```

---

# 🔄 CI/CD Pipeline

The project contains three GitHub Actions workflows:

```text
.github/workflows/

├── terraform-check.yml
├── terraform-plan.yml
└── terraform-apply.yml
```

The workflows handle different stages of the infrastructure lifecycle.

---

# 1️⃣ Terraform Check

The check workflow runs on code changes and pull requests.

It performs:

```text
Terraform Format
       ↓
Terraform Validate
       ↓
Security Scanning
```

Security tools include:

```text
Checkov
Trivy
```

This allows infrastructure problems and security issues to be detected before deployment.

---

# 2️⃣ Terraform Plan

The plan workflow runs for pull requests.

Its purpose is to show exactly what Terraform intends to change before the infrastructure is applied.

```text
Pull Request
     │
     ▼
Terraform Plan
     │
     ▼
Infrastructure Diff
     │
     ▼
Review
```

The generated plan is posted back to the pull request so infrastructure changes can be reviewed before merging.

---

# 3️⃣ Terraform Apply

The apply workflow handles the deployment stage.

The overall flow is:

```text
Code Change
    │
    ▼
Build Docker Image
    │
    ▼
Deploy Development
    │
    ▼
Deploy Production
```

The repository architecture documentation describes the apply workflow as the stage responsible for building the Docker image and deploying the development and production environments.

---

# 🔐 AWS Authentication

The CI/CD system uses **GitHub OIDC** for AWS authentication.

Instead of storing a permanent AWS access key and secret in GitHub, GitHub Actions can authenticate through an AWS IAM role.

```text
GitHub Actions
      │
      │ OIDC Token
      ▼
AWS IAM
      │
      │ Assume Role
      ▼
AWS Resources
```

This avoids keeping long-lived AWS credentials inside the repository or GitHub secrets.

---

# 🔒 Security

Security is integrated into multiple layers.

## Infrastructure

Terraform manages:

```text
IAM
Security Groups
Encrypted EBS
VPC
```

## CI/CD

The pipeline includes:

```text
Checkov
Trivy
```

for security scanning.

## AWS Authentication

GitHub Actions uses:

```text
OIDC
```

instead of long-lived AWS credentials.

## EC2

The application server uses:

```text
IAM Instance Role
```

instead of hardcoded AWS credentials.

## Container

The application container runs as a:

```text
Non-root user
```

---

# 🧭 Complete Deployment Flow

The complete workflow is:

```text
                    Developer
                       │
                       │ git push
                       ▼
                  GitHub Repo
                       │
             ┌─────────┴─────────┐
             │                   │
             ▼                   ▼
       Terraform Check      Terraform Plan
             │                   │
             ├── Format          └── Infrastructure Diff
             ├── Validate
             ├── Checkov
             └── Trivy
             │
             ▼
           Merge
             │
             ▼
      Terraform Apply
             │
             ▼
       Build Docker Image
             │
             ▼
        AWS Deployment
             │
             ▼
      Terraform Modules
             │
       ┌─────┼─────┬───────────┐
       │     │     │           │
       ▼     ▼     ▼           ▼
      VPC Security EC2     Monitoring
             │
             ▼
        EC2 Instance
             │
             ▼
      Amazon Linux 2023
             │
             ▼
           Docker
             │
             ▼
        Flask App
             │
             ▼
        /health
```

---

# 🖥️ EC2 Bootstrap Flow

When Terraform creates an EC2 instance:

```text
EC2 Created
    │
    ▼
Amazon Linux 2023
    │
    ▼
User Data Executes
    │
    ├── Update packages
    │
    ├── Install Docker
    │
    ├── Start Docker
    │
    ├── Enable Docker
    │
    ├── Pull Docker image
    │
    ├── Start container
    │
    └── Verify /health
    │
    ▼
Application Running
```

The bootstrap script also logs its output to:

```text
/var/log/user-data.log
```

which can be useful for troubleshooting instance initialization.

---

# 🧪 Local Development

## Requirements

Install:

```text
Git
Terraform 1.6+
AWS CLI 2+
Docker 24+
Python 3.10+
```

These are the minimum versions listed by the project's deployment documentation.

---

# 📥 Clone Repository

```bash
git clone https://github.com/Gauravb741/tf-aws-infra.git
```

Enter the project:

```bash
cd tf-aws-infra
```

---

# 🐍 Run Flask Application Locally

Enter the application directory:

```bash
cd app
```

Create a virtual environment:

```bash
python3 -m venv .venv
```

Activate:

```bash
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Run:

```bash
python src/app.py
```

The application runs on:

```text
http://localhost:5000
```

---

# 🐳 Build Docker Image

From the `app` directory:

```bash
docker build -t terraform-aws-app .
```

Run:

```bash
docker run -d \
  --name terraform-aws-app \
  -p 5000:5000 \
  terraform-aws-app
```

Check:

```bash
curl http://localhost:5000/health
```

---

# 🏗️ Terraform

Move to the development environment:

```bash
cd terraform/environments/dev
```

Initialize Terraform:

```bash
terraform init
```

Format:

```bash
terraform fmt -recursive
```

Validate:

```bash
terraform validate
```

Create a plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

---

# 🚀 Production Deployment

Move to:

```bash
cd terraform/environments/prod
```

Initialize:

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Create a plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

---

# 🔍 Terraform Commands

### Format

```bash
terraform fmt -recursive
```

### Initialize

```bash
terraform init
```

### Validate

```bash
terraform validate
```

### Plan

```bash
terraform plan
```

### Apply

```bash
terraform apply
```

### Show State

```bash
terraform show
```

### List Resources

```bash
terraform state list
```

### Destroy

```bash
terraform destroy
```

---

# 📜 Deployment Scripts

The repository includes helper scripts:

```text
terraform/scripts/

├── bootstrap-state.sh
├── deploy.sh
├── destroy.sh
└── setup.sh
```

These scripts simplify common infrastructure operations.

---

# 🗄️ Terraform State

Terraform state is important because it tracks the relationship between the Terraform configuration and the AWS resources that actually exist.

The project architecture describes an encrypted remote state approach using:

```text
S3
+
DynamoDB locking
```

This provides:

* Centralized state
* State encryption
* Locking
* Reduced concurrent modification problems
* Better separation between infrastructure environments

---

# 🔄 Development vs Production

The two environments share the same modules:

```text
                Terraform Modules
                       │
             ┌─────────┴─────────┐
             │                   │
             ▼                   ▼
           DEV                  PROD
             │                   │
       Different Values    Different Values
```

This avoids duplicating the infrastructure implementation.

For example:

```text
Module:
terraform/modules/ec2
```

is reused by both:

```text
terraform/environments/dev
terraform/environments/prod
```

The environments simply pass different variable values.

---

# 🧹 Destroy Infrastructure

To remove an environment:

```bash
terraform destroy
```

For development:

```bash
cd terraform/environments/dev
terraform destroy
```

For production:

```bash
cd terraform/environments/prod
terraform destroy
```

Always verify the Terraform plan before confirming destruction.

---

# 🔍 Troubleshooting

## Check EC2

```bash
aws ec2 describe-instances
```

## Check Docker

```bash
docker ps
```

## Check application logs

```bash
docker logs devops-app
```

## Check container health

```bash
docker inspect devops-app
```

## Check user-data logs

```bash
sudo cat /var/log/user-data.log
```

## Check Docker service

```bash
sudo systemctl status docker
```

## Check application

```bash
curl http://localhost:<application-port>/health
```

---

# 🔐 Important Configuration

Before deploying the infrastructure, review the environment variables and Terraform variables for:

```text
AWS Region
Project Name
Environment
VPC CIDR
Public Subnet CIDR
Private Subnet CIDR
EC2 Instance Type
SSH CIDR
Key Pair
Application Port
Docker Image
Application Version
CPU Alarm Threshold
Log Retention
```

Do not commit:

```text
AWS Access Keys
AWS Secret Keys
Private SSH Keys
Sensitive credentials
Production secrets
```

---

# 📦 Docker Image Flow

The application image follows this process:

```text
Flask Source Code
       │
       ▼
Docker Build
       │
       ▼
Docker Image
       │
       ▼
Container Registry
       │
       ▼
EC2 User Data
       │
       ▼
docker pull
       │
       ▼
Docker Container
       │
       ▼
Flask + Gunicorn
```

The current bootstrap script is configured to pull the Docker image specified by Terraform. The repository notes that a production-oriented implementation could use Amazon ECR instead of Docker Hub.

---

# 📊 Infrastructure Summary

```text
AWS
│
├── VPC
│   │
│   ├── Public Subnet
│   │   ├── EC2
│   │   └── Internet Gateway
│   │
│   └── Private Subnet
│
├── Security Group
│   ├── SSH
│   ├── Application Port
│   └── Outbound
│
├── IAM
│   ├── EC2 Role
│   ├── CloudWatch Permissions
│   └── SSM Permissions
│
├── EC2
│   ├── Amazon Linux 2023
│   ├── Docker
│   ├── Flask
│   └── Gunicorn
│
└── CloudWatch
    ├── Log Group
    ├── CPU Alarm
    ├── Status Alarm
    └── Dashboard
```

---

# 🔁 Infrastructure Lifecycle

```text
Terraform Configuration
          │
          ▼
     terraform plan
          │
          ▼
      Review Changes
          │
          ▼
     terraform apply
          │
          ▼
     AWS Resources
          │
          ▼
      Application
          │
          ▼
       Monitoring
          │
          ▼
     Configuration Change
          │
          ▼
      Terraform Plan
          │
          ▼
      Terraform Apply
```

---

# 🎯 What This Project Demonstrates

```text
Infrastructure as Code
        +
AWS Cloud
        +
Terraform Modules
        +
Environment Management
        +
Docker
        +
EC2
        +
IAM
        +
CloudWatch
        +
GitHub Actions
        +
Security Scanning
        +
OIDC Authentication
        =
Automated AWS DevOps Platform
```

The key idea is to manage both infrastructure and application deployment through reproducible configuration rather than manually creating and configuring AWS resources.

---

# 🚀 End-to-End Summary

```text
┌──────────────────────────────────────────────────────────────┐
│                    AWS DEVOPS PLATFORM                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Developer                                                   │
│      │                                                       │
│      ▼                                                       │
│  GitHub                                                      │
│      │                                                       │
│      ▼                                                       │
│  GitHub Actions                                              │
│      │                                                       │
│      ├── Terraform Format                                    │
│      ├── Terraform Validate                                  │
│      ├── Checkov                                             │
│      ├── Trivy                                               │
│      └── Terraform Plan                                      │
│      │                                                       │
│      ▼                                                       │
│  Terraform                                                   │
│      │                                                       │
│      ├── VPC                                                 │
│      ├── Security Groups                                     │
│      ├── IAM                                                 │
│      ├── EC2                                                 │
│      └── CloudWatch                                          │
│      │                                                       │
│      ▼                                                       │
│  AWS EC2                                                     │
│      │                                                       │
│      ├── Amazon Linux 2023                                   │
│      ├── Docker                                               │
│      └── IAM Role                                             │
│      │                                                       │
│      ▼                                                       │
│  Flask Application                                            │
│      │                                                       │
│      ├── /                                                    │
│      └── /health                                              │
│      │                                                       │
│      ▼                                                       │
│  CloudWatch                                                   │
│      │                                                       │
│      ├── Logs                                                 │
│      ├── CPU Alarm                                            │
│      ├── Status Alarm                                         │
│      └── Dashboard                                            │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

**Git → GitHub Actions → Terraform → AWS → EC2 → Docker → Flask → CloudWatch**
