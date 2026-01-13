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

## Troubleshooting

### `/break` endpoint doesn't seem to work with multiple replicas

If you visit `/break` and then immediately check `/health`, you might still see `"ok"` instead of `"error"`. This is expected behavior when running multiple replicas.

**Why this happens:**
- Each pod runs its own Flask instance with its own `healthy` state variable
- The LoadBalancer service distributes requests across all pods
- When you visit `/break`, it only affects the specific pod that handled that request
- The next request to `/health` might hit a different pod that still has `healthy = True`

**Solutions:**

1. **Scale down to 1 replica for testing:**
   ```bash
   kubectl scale deployment kubernetes-experiments-deployment --replicas=1
   ```
   After testing, scale back up:
   ```bash
   kubectl scale deployment kubernetes-experiments-deployment --replicas=2
   ```

2. **Use port-forwarding to target a specific pod:**
   ```bash
   kubectl port-forward <pod-name> 8080:80
   ```
   Then access `http://localhost:8080/break` and `http://localhost:8080/health` on that specific pod.

## Project Structure

- `main.py` - Flask application with `/health` and `/break` endpoints
- `Dockerfile` - Container image definition using `uv`
- `kubernetes-experiments-deployment.yaml` - Kubernetes deployment manifest
- `kubernetes-experiments-service.yaml` - Kubernetes service manifest
