# Kubernetes Experiments

A simple Flask application to experiment with Kubernetes features like deployments, services, and liveness probes.

## What it does

This project demonstrates:
- Kubernetes deployments with multiple replicas
- LoadBalancer services
- Liveness probes for health checking
- Automatic pod restart on failures

## Setup

1. Ensure Kubernetes is enabled in Docker Desktop
2. Install dependencies using `uv`:
   ```bash
   uv sync
   ```

## Building and Deploying

1. Build and push the Docker image:
   ```bash
   docker build -t tonyvallad/kubernetes-experiments:latest .
   docker push tonyvallad/kubernetes-experiments:latest
   ```

2. Apply the Kubernetes manifests:
   ```bash
   kubectl apply -f kubernetes-experiments-deployment.yaml
   kubectl apply -f kubernetes-experiments-service.yaml
   ```

3. Access the application at `http://localhost:8003`

## Testing

- Visit `/health` to check the health status
- Visit `/break` to simulate a failure (causes the liveness probe to fail)
- Kubernetes will automatically restart unhealthy pods

## Project Structure

- `main.py` - Flask application with `/health` and `/break` endpoints
- `Dockerfile` - Container image definition using `uv`
- `kubernetes-experiments-deployment.yaml` - Kubernetes deployment manifest
- `kubernetes-experiments-service.yaml` - Kubernetes service manifest
