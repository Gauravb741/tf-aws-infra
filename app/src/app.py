"""
Terraform AWS DevOps Platform - Demo Application

A minimal Flask application demonstrating containerised deployment
on AWS EC2 via Terraform and GitHub Actions CI/CD.

Endpoints:
  GET /        - Application information
  GET /health  - Health check for load balancers and Docker healthchecks
"""

import os
import socket
from datetime import datetime, timezone

from flask import Flask, jsonify

app = Flask(__name__)

# Configuration pulled from environment variables set by Terraform user-data
# or Docker run arguments, with safe defaults for local development.
APP_VERSION = os.environ.get("APP_VERSION", "1.0.0")
ENVIRONMENT = os.environ.get("ENVIRONMENT", "local")
APP_PORT = int(os.environ.get("APP_PORT", "5000"))
START_TIME = datetime.now(timezone.utc)


def get_uptime_seconds() -> float:
    """Return number of seconds since application started."""
    delta = datetime.now(timezone.utc) - START_TIME
    return round(delta.total_seconds(), 2)


@app.route("/", methods=["GET"])
def index():
    """
    Root endpoint.
    Returns basic platform information so the deployment can be verified.
    """
    return jsonify(
        {
            "application": "Terraform AWS DevOps Platform",
            "environment": ENVIRONMENT,
            "version": APP_VERSION,
            "status": "running",
            "hostname": socket.gethostname(),
            "uptime_seconds": get_uptime_seconds(),
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    ), 200


@app.route("/health", methods=["GET"])
def health():
    """
    Health check endpoint.

    Returns HTTP 200 when the application is healthy.
    Used by:
      - Docker HEALTHCHECK instruction
      - CloudWatch agent (optional)
      - External monitoring tools
    """
    return jsonify(
        {
            "status": "healthy",
            "version": APP_VERSION,
            "environment": ENVIRONMENT,
            "uptime_seconds": get_uptime_seconds(),
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    ), 200


@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "not found", "path": "use GET / or GET /health"}), 404


@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "internal server error"}), 500


if __name__ == "__main__":
    # Development only — production uses gunicorn
    app.run(host="0.0.0.0", port=APP_PORT, debug=False)