# Server Deployment Guide

This guide covers deploying the UCNRS RAMS application using the server Dockerfile to AWS, development preview servers, staging, or other cloud providers. The `Dockerfile.server` is optimized for remote server deployments across all non-local environments.

## Overview

The server Dockerfile (`Dockerfile.server`) is optimized for remote server deployments with the following features:

- **Multi-stage build**: Separates build and runtime environments to minimize final image size
- **Production dependencies only**: Excludes development and test gems/packages
- **Precompiled assets**: Assets are compiled during the build process
- **Optimized Puma configuration**: Multi-worker, multi-threaded setup for production workloads
- **Non-root user**: Application runs as a non-root user for enhanced security
- **Health checks**: Built-in health check endpoint
- **Minimal runtime image**: Only includes necessary runtime dependencies

## Building the Server Image

### Basic Build

```bash
docker build -f Dockerfile.server -t ucnrs-rams:latest .
```

### Build with Version Tag

```bash
docker build -f Dockerfile.server -t ucnrs-rams:v1.0.0 .
```

### Build for Different Architecture (e.g., ARM64 for AWS Graviton)

```bash
docker buildx build --platform linux/amd64 -f Dockerfile.server -t ucnrs-rams:latest .
```

## Required Environment Variables

The application requires the following environment variables to run in production:

### Rails Core
- `RAILS_ENV=production`
- `SECRET_KEY_BASE` - Secret key for encrypting sessions (generate with `rails secret`)
- `RAILS_MASTER_KEY` or `RAILS_CREDENTIALS_KEY` - For decrypting credentials

### Database
- `DATABASE_HOST` - Database server hostname
- `DATABASE_NAME` - Database name
- `DATABASE_USERNAME` - Database username
- `DATABASE_PASSWORD` - Database password
- `DATABASE_PORT` - Database port (default: 3306 for MySQL)

### Email/SMTP
- `HOST` - Application hostname (e.g., rams.ucnrs.org)
- `PROTOCOL` - http or https (default: https)
- `SMTP_HOST` - SMTP server hostname
- `SMTP_PORT` - SMTP server port
- `SMTP_DOMAIN` - SMTP domain
- `SMTP_USERNAME` - SMTP username
- `SMTP_PASSWORD` - SMTP password

### Storage (if using AWS S3)
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_BUCKET`

### Puma Configuration (Optional)
- `WEB_CONCURRENCY` - Number of Puma workers (default: 2, recommend 1 per CPU core)
- `RAILS_MAX_THREADS` - Maximum threads per worker (default: 5)
- `RAILS_MIN_THREADS` - Minimum threads per worker (default: same as max)
- `PORT` - Port to bind to (default: 3000)

## Running the Container Locally

For local testing of the server image:

```bash
docker run -p 3000:3000 \
  -e SECRET_KEY_BASE=your_secret_key \
  -e DATABASE_HOST=your_db_host \
  -e DATABASE_NAME=your_db_name \
  -e DATABASE_USERNAME=your_db_user \
  -e DATABASE_PASSWORD=your_db_password \
  # ... add other required environment variables
  ucnrs-rams:latest
```

## AWS Deployment Options

### Option 1: Amazon ECS (Elastic Container Service)

1. **Push image to ECR (Elastic Container Registry)**

```bash
# Authenticate to ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com

# Tag image
docker tag ucnrs-rams:latest YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/ucnrs-rams:latest

# Push image
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/ucnrs-rams:latest
```

2. **Create ECS Task Definition**
   - Use the ECR image URI
   - Configure environment variables or use AWS Secrets Manager
   - Set CPU/Memory limits (recommend at least 1 vCPU, 2GB RAM)
   - Configure health check endpoint: `/up`

3. **Create ECS Service**
   - Choose Fargate or EC2 launch type
   - Configure load balancer
   - Set desired task count (minimum 2 for high availability)

### Option 2: Amazon EKS (Kubernetes)

Create a Kubernetes deployment manifest:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ucnrs-rams
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ucnrs-rams
  template:
    metadata:
      labels:
        app: ucnrs-rams
    spec:
      containers:
      - name: ucnrs-rams
        image: YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/ucnrs-rams:latest
        ports:
        - containerPort: 3000
        env:
        - name: RAILS_ENV
          value: "production"
        # Add other environment variables from ConfigMap or Secrets
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /up
            port: 3000
          initialDelaySeconds: 40
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /up
            port: 3000
          initialDelaySeconds: 20
          periodSeconds: 5
```

### Option 3: AWS App Runner

AWS App Runner is the simplest option for containerized Rails apps:

1. Push image to ECR (as shown above)
2. Create App Runner service via AWS Console or CLI
3. Configure environment variables
4. App Runner handles auto-scaling and load balancing

### Option 4: Amazon Lightsail Containers

Good for smaller deployments with predictable traffic:

```bash
aws lightsail create-container-service \
  --service-name ucnrs-rams \
  --power small \
  --scale 1
```

## Database Migrations

Before deploying a new version, run database migrations:

```bash
# For ECS/Fargate, create a one-off task:
docker run --rm \
  -e RAILS_ENV=production \
  -e DATABASE_HOST=... \
  # ... other env vars
  ucnrs-rams:latest \
  bundle exec rails db:migrate

# For Kubernetes, use a Job:
kubectl run rails-migrate --rm -it \
  --image=YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/ucnrs-rams:latest \
  --restart=Never \
  --env="RAILS_ENV=production" \
  -- bundle exec rails db:migrate
```

## Performance Tuning

### Puma Workers and Threads

- **Workers**: Set `WEB_CONCURRENCY` to match your container's CPU cores
  - 1 vCPU → 1 worker
  - 2 vCPU → 2 workers
  - 4 vCPU → 3-4 workers

- **Threads**: Set `RAILS_MAX_THREADS` based on your I/O workload
  - I/O heavy (many database queries): 5-10 threads
  - CPU heavy: 2-5 threads

### Database Connection Pool

Match `RAILS_MAX_THREADS` in your database.yml or set via environment:

```yaml
production:
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

### Memory Considerations

- Baseline: ~150-200MB per Puma worker
- Add: ~10-20MB per thread
- Example: 2 workers × 5 threads ≈ 500-600MB minimum
- Recommend: 1-2GB memory allocation

## Monitoring and Logging

### Health Check Endpoint

The Dockerfile includes a health check on `/up` endpoint. Ensure this route exists in your Rails app:

```ruby
# config/routes.rb
get "up" => "rails/health#show", as: :rails_health_check
```

### Application Logs

Logs are written to STDOUT and can be accessed via:

```bash
# ECS/Fargate
aws logs tail /ecs/ucnrs-rams --follow

# Kubernetes
kubectl logs -f deployment/ucnrs-rams

# Docker
docker logs -f container_id
```

### Recommended Monitoring

- AWS CloudWatch (for ECS/EKS)
- Datadog, New Relic, or Scout APM for application monitoring
- Database monitoring (RDS Performance Insights)

## Security Best Practices

1. **Secrets Management**
   - Use AWS Secrets Manager or Parameter Store for sensitive data
   - Never commit secrets to version control
   - Rotate credentials regularly

2. **Image Scanning**
   ```bash
   # Scan for vulnerabilities before deploying
   aws ecr start-image-scan --repository-name ucnrs-rams --image-id imageTag=latest
   ```

3. **Network Security**
   - Run containers in private subnets
   - Use security groups to restrict access
   - Enable VPC endpoints for AWS services

4. **Regular Updates**
   - Keep base images updated (Ruby, Node.js)
   - Update gems regularly (`bundle update`)
   - Monitor CVEs for dependencies

## Troubleshooting

### Container won't start

Check logs for errors:
```bash
docker logs container_id
```

Common issues:
- Missing environment variables
- Database connection failure
- Failed asset precompilation

### Out of Memory

Reduce `WEB_CONCURRENCY` or `RAILS_MAX_THREADS`, or increase container memory.

### Slow Performance

- Check database query performance
- Enable query caching
- Consider Redis for caching
- Adjust worker/thread counts

## Rollback Strategy

1. Tag images with version numbers
2. Keep previous versions in ECR
3. Update ECS/K8s to use previous image tag
4. Run database migrations in backward-compatible way

## CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-west-2

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build and push
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: ucnrs-rams
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -f Dockerfile.server -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

      - name: Deploy to ECS
        run: |
          # Update ECS service with new image
          aws ecs update-service --cluster your-cluster --service ucnrs-rams --force-new-deployment
```

## Additional Resources

- [Puma Configuration](https://github.com/puma/puma#configuration)
- [Rails Production Guide](https://guides.rubyonrails.org/production.html)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

