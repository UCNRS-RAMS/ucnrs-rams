# Server Dockerfile - Summary of Changes

This document outlines the server Docker setup created for the UCNRS RAMS application, used for development preview, staging, and production environments.

## Files Created

1. **Dockerfile.server** - Server-optimized Dockerfile for remote deployments
2. **config/puma.production.rb** - Production Puma configuration
3. **.dockerignore** - Excludes unnecessary files from Docker build context
4. **docker-compose.server.yml** - For local testing of server image
5. **.env.production.template** - Template for environment variables
6. **DEPLOYMENT.md** - Comprehensive deployment guide
7. **config/routes.rb** - Modified to add health check endpoint

## Key Differences: Development vs Server Dockerfile

### Multi-Stage Build
- **Development**: Single-stage build, installs everything
- **Server**: Three-stage build (node → builder → runtime)
  - Separates build-time and runtime dependencies
  - Significantly smaller final image size
  - Only includes what's needed to run the app

### Dependencies
- **Development**: Installs ALL gems and packages including dev/test
  ```ruby
  bundle install
  yarn install --check-files
  ```
- **Server**: Excludes development and test dependencies
  ```ruby
  bundle config set --local without 'development test'
  bundle install --jobs 4 --retry 3
  yarn install --production --frozen-lockfile --non-interactive
  ```

### Build Tools and Dependencies
- **Development**:
  - Includes full build-essential
  - Chromium and chromium-driver for testing
  - All development libraries
- **Server**:
  - Builder stage: Full build tools for compilation
  - Runtime stage: Only minimal runtime libraries
  - No testing frameworks or browsers

### Asset Compilation
- **Development**: Assets compiled on-demand by Rails
- **Server**: Assets precompiled during Docker build
  ```bash
  RAILS_ENV=production SECRET_KEY_BASE=placeholder bundle exec rails assets:precompile
  ```

### Puma Configuration
- **Development**:
  - Single worker (or workers commented out)
  - Long worker timeout (3600s) for debugging
  - Development environment defaults
- **Server**:
  - Multiple workers (default 2, configurable via WEB_CONCURRENCY)
  - Worker clustering with preload_app!
  - Optimized for production traffic
  - Shorter timeouts (30s)
  - Better logging for container environments

### Security
- **Development**: Runs as root user
- **Server**:
  - Creates and uses non-root 'rails' user
  - Restricts file permissions
  - Follows security best practices

### Image Size Optimization
- **Development**: ~1.5-2GB (includes all dependencies and tools)
- **Server**: ~800MB-1GB (minimal runtime image)
  - Multi-stage build discards build tools
  - No dev/test dependencies
  - Cleaned apt cache and temporary files

### Environment Variables
- **Development**: Minimal required, uses defaults
- **Server**: Explicit configuration required:
  - SECRET_KEY_BASE
  - Database credentials
  - SMTP configuration
  - AWS credentials (if using S3)
  - RAILS_ENV=production
  - RAILS_LOG_TO_STDOUT=true

### Health Checks
- **Development**: No health checks
- **Server**:
  - Built-in Docker HEALTHCHECK directive
  - Checks /up endpoint every 30 seconds
  - Used by orchestration platforms (ECS, K8s) for container health

### Volumes
- **Development**:
  - Mounts entire codebase for live reloading
  - Database persisted in named volume
- **Server**:
  - Code copied into image (immutable)
  - Only data volumes for uploads/storage
  - Database external (RDS, managed service)

### Logging
- **Development**: Logs to files in log/ directory
- **Server**:
  - STDOUT/STDERR for container log aggregation
  - Compatible with CloudWatch, Datadog, etc.
  - JSON-formatted logs (optional)

### Command
- **Development**:
  ```dockerfile
  CMD ["rails", "server", "-b", "0.0.0.0"]
  ```
- **Server**:
  ```dockerfile
  CMD ["bundle", "exec", "puma", "-C", "config/puma.production.rb"]
  ```

## Performance Comparison

### Development
- **Purpose**: Fast iteration, debugging
- **Startup**: Slower (loads code on demand)
- **Memory**: Lower baseline, but can grow
- **Concurrency**: Single-threaded or minimal
- **Caching**: Disabled or minimal

### Server
- **Purpose**: Maximum performance and reliability across dev preview, staging, and production
- **Startup**: Faster (preloaded application)
- **Memory**: Higher baseline (preloaded), more stable
- **Concurrency**: Multi-worker, multi-threaded
- **Caching**: Aggressive caching enabled

## Resource Requirements

### Development Container
- **Minimum**: 512MB RAM, 1 CPU
- **Recommended**: 1GB RAM, 1-2 CPU

### Server Container
- **Minimum**: 1GB RAM, 1 CPU (for 2 workers)
- **Recommended**: 2GB RAM, 2 CPU (for staging/production traffic)
- **Scaling**: Add workers as you add CPU cores
  - 1 vCPU → 1 worker
  - 2 vCPU → 2 workers
  - 4 vCPU → 3-4 workers

## Build Time Comparison

### Development
- **Initial build**: 5-10 minutes
- **Rebuild**: Fast (uses cached layers)
- **Code changes**: No rebuild needed (mounted volumes)

### Server
- **Initial build**: 8-15 minutes (includes asset compilation)
- **Rebuild**: 8-15 minutes (immutable, no shortcuts)
- **Code changes**: Full rebuild required

## Deployment Workflow

### Development
1. Start container with docker-compose
2. Edit code locally
3. Changes reflected immediately
4. Test in browser

### Server (Dev Preview, Staging, Production)
1. Build server image with version tag
2. Run automated tests (CI/CD)
3. Push to container registry (ECR)
4. Run database migrations (if needed)
5. Deploy to orchestration platform (ECS/K8s)
6. Health checks verify deployment
7. Load balancer routes traffic to new containers
8. Monitor logs and metrics

## Testing Server Image Locally

```bash
# Build server image
docker build -f Dockerfile.server -t ucnrs-rams:test .

# Test with docker-compose
cp .env.production.template .env.server
# Edit .env.server with test values
docker-compose -f docker-compose.server.yml up

# Run migrations
docker-compose -f docker-compose.server.yml exec app bundle exec rails db:migrate

# Access at http://localhost:3000
```

## Migration Path

To move from development to remote server deployment:

1. **Test locally**: Use docker-compose.server.yml
2. **Set up AWS infrastructure** (for the target environment):
   - RDS for database
   - ECR for container registry
   - ECS/EKS/App Runner for orchestration
   - S3 for file storage
   - ALB for load balancing
3. **Configure secrets**: Use AWS Secrets Manager
4. **Set up CI/CD**: GitHub Actions, CodePipeline, etc.
5. **Deploy**: Push to your environment (dev preview, staging, or production)
6. **Monitor**: Set up logging and metrics

## Rollback Procedures

### Development
- Revert code changes
- Restart container

### Server
- Tag images with versions
- Keep previous versions in ECR
- Update orchestration to use previous image tag
- Database migrations must be backward-compatible

## Common Issues and Solutions

### Issue: Out of Memory
- **Development**: Increase Docker Desktop memory
- **Production**: Reduce WEB_CONCURRENCY or increase container memory

### Issue: Slow Startup
- **Development**: Reduce gems, optimize Gemfile
- **Production**: Already optimized with preload_app!

### Issue: Asset 404 Errors
- **Development**: Check shakapacker dev server
- **Production**: Ensure assets:precompile ran successfully in build

### Issue: Database Connection Errors
- **Development**: Check docker-compose DB service
- **Production**: Check security groups, VPC settings, credentials

## Security Considerations

### Development
- Not exposed to internet
- Debug tools enabled
- Secrets in plain .env files (acceptable for local dev)

### Server (Dev Preview, Staging, Production)
- Publicly accessible (needs hardening)
- Debug tools disabled
- Secrets in encrypted storage (Secrets Manager)
- Regular security updates required
- Image scanning for vulnerabilities
- Network isolation (VPC, security groups)
- HTTPS enforced (especially for production)
- Non-root user

## Cost Implications

### Development
- **Cost**: $0 (runs locally)
- **Resource**: Uses your laptop/desktop

### Server Deployment
- **Compute**: ECS/EKS charges (varies by instance type)
- **Database**: RDS charges
- **Storage**: S3, EBS charges
- **Network**: Data transfer charges
- **Example monthly cost** (small dev preview/staging):
  - ECS Fargate (0.5 vCPU, 1GB): ~$15-30/mo
  - RDS MySQL (db.t3.small): ~$30-50/mo
  - S3 storage: ~$1-5/mo
  - ALB: ~$20/mo
  - **Total**: ~$70-110/mo (varies by traffic and region)
- **Example monthly cost** (production):
  - ECS Fargate (2 vCPU, 4GB with 3 tasks): ~$90-150/mo
  - RDS MySQL (db.t3.medium): ~$100-150/mo
  - S3 storage: ~$5-20/mo
  - ALB: ~$20/mo
  - **Total**: ~$215-340/mo (varies by traffic and region)

## Next Steps

1. Review DEPLOYMENT.md for detailed AWS deployment instructions
2. Test server image locally with docker-compose.server.yml
3. Set up AWS infrastructure (RDS, ECR, ECS/EKS)
4. Configure environment variables and secrets
5. Set up CI/CD pipeline
6. Deploy to development preview server first
7. Deploy to staging environment second
8. Monitor and optimize based on real traffic
9. Deploy to production
10. Set up automated backups and disaster recovery

## Additional Resources

- Server Dockerfile: `Dockerfile.server`
- Deployment Guide: `DEPLOYMENT.md`
- Docker Compose: `docker-compose.server.yml`
- Puma Config: `config/puma.production.rb`
- Environment Template: `.env.production.template`

