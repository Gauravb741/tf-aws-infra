#!/bin/bash
# =============================================================================
# EC2 User Data Script
#
# Runs as root on first boot via cloud-init.
# Installs Docker and deploys the application container.
#
# set -euo pipefail causes the script to exit immediately if:
#   -e  any command returns a non-zero exit code
#   -u  any undefined variable is referenced
#   -o pipefail  any command in a pipeline fails
# =============================================================================
set -euo pipefail

# Redirect all output to a log file for troubleshooting
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "============================================="
echo "  ${project_name} — ${environment} bootstrap"
echo "  $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "============================================="

# -----------------------------------------------------------------------------
# System update
# -----------------------------------------------------------------------------
echo "[1/5] Updating system packages..."
dnf update -y --quiet

# -----------------------------------------------------------------------------
# Install Docker
# Amazon Linux 2023 ships Docker in its standard repos.
# -----------------------------------------------------------------------------
echo "[2/5] Installing Docker..."
dnf install -y docker

# Start and enable Docker so it restarts after a reboot
systemctl start docker
systemctl enable docker

# Add ec2-user to the docker group so the app user can run Docker commands
# without sudo — reduces attack surface by not requiring root for container ops
usermod -aG docker ec2-user

echo "Docker version: $(docker --version)"

# -----------------------------------------------------------------------------
# Pull Docker image
#
# Uses the public Docker Hub image built by GitHub Actions.
# For production environments, replace with an ECR image to avoid Docker Hub
# rate limits and to keep images private.
# -----------------------------------------------------------------------------
echo "[3/5] Pulling application image: ${docker_image}..."
docker pull "${docker_image}"

# -----------------------------------------------------------------------------
# Run application container
#
# --restart unless-stopped: Docker automatically restarts the container
#   if it crashes or if the Docker daemon restarts (e.g. after OS reboot).
#   This replaces the need for a separate systemd service for the app.
#
# --health-cmd: Docker checks the /health endpoint every 30 seconds.
#   If 3 consecutive checks fail, Docker marks the container unhealthy.
# -----------------------------------------------------------------------------
echo "[4/5] Starting application container..."

# Stop and remove any existing container from a previous deployment
docker stop devops-app 2>/dev/null || true
docker rm devops-app 2>/dev/null || true

docker run -d \
  --name devops-app \
  --restart unless-stopped \
  -p "${application_port}":5000 \
  -e ENVIRONMENT="${environment}" \
  -e APP_VERSION="${app_version}" \
  "${docker_image}"

# -----------------------------------------------------------------------------
# Verify deployment
# -----------------------------------------------------------------------------
echo "[5/5] Verifying deployment..."

# Wait for the container to become healthy (up to 60 seconds)
TIMEOUT=60
INTERVAL=5
ELAPSED=0

while [ $ELAPSED -lt $TIMEOUT ]; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' devops-app 2>/dev/null || echo "unknown")
  
  if [ "$STATUS" = "healthy" ]; then
    echo "Container is healthy after $${ELAPSED}s"
    break
  fi
  
  if [ "$STATUS" = "unhealthy" ]; then
    echo "ERROR: Container is unhealthy. Logs:"
    docker logs devops-app
    exit 1
  fi
  
  echo "Container status: $${STATUS} — waiting..."
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

# Final check via HTTP
HTTP_STATUS=$(curl -s -o /dev/null -w "%%{http_code}" "http://localhost:${application_port}/health" || echo "000")

if [ "$HTTP_STATUS" = "200" ]; then
  echo "SUCCESS: Application is responding on port ${application_port}"
  echo "Health check: http://localhost:${application_port}/health"
else
  echo "ERROR: Application health check returned HTTP $${HTTP_STATUS}"
  echo "Container logs:"
  docker logs devops-app
  exit 1
fi

echo "============================================="
echo "  Bootstrap complete"
echo "  $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "============================================="