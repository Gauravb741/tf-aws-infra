# Demo Application

A minimal Python Flask web application used to demonstrate:

- Containerised deployment with Docker
- AWS EC2 deployment via Terraform
- Health checking at container and CloudWatch level

## Endpoints

| Endpoint  | Method | Description                  |
|-----------|--------|------------------------------|
| `/`       | GET    | Application information      |
| `/health` | GET    | Health check (returns 200)   |

## Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run development server
python src/app.py