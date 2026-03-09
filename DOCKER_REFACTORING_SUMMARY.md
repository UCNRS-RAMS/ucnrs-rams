# Docker Configuration Refactoring - Summary

## Changes Made

This refactoring improves the clarity and correctness of the Docker configuration naming to better reflect actual usage across development preview, staging, and production environments.

### File Renames

1. **Dockerfile.production** → **Dockerfile.server**
   - Reflects that this Dockerfile is used for all remote server deployments, not just production
   - Eliminates confusion when deploying to development preview or staging servers

2. **docker-compose.production.yml** → **docker-compose.server.yml**
   - Aligns with the new Dockerfile naming
   - Used for local testing of the server image before remote deployment

### Updated References

The following files have been updated to reference the new file names:

- ✅ `docker-compose.server.yml` - Updated dockerfile reference
- ✅ `DEPLOYMENT.md` - Updated all command examples and documentation
- ✅ `PRODUCTION_DOCKERFILE_SUMMARY.md` - Updated file references and examples
- ✅ `scripts/docker-deploy.sh` - Updated DOCKERFILE variable and comments
- ✅ `scripts/docker-deploy.sh` - Updated docker-compose reference for migrations

### New Documentation

- ✅ `DOCKERFILE_NAMING_RATIONALE.md` - Explains the naming convention and rationale

## Quick Reference

### Local Development
```bash
docker-compose -f docker-compose.yml up
```

### Test Server Image Locally
```bash
docker-compose -f docker-compose.server.yml up
# or
docker build -f Dockerfile.server -t ucnrs-rams:latest .
docker run -p 3000:3000 [env vars] ucnrs-rams:latest
```

### Deploy to Remote Servers
```bash
# Build the server image
docker build -f Dockerfile.server -t ucnrs-rams:v1.0.0 .

# Push to ECR
docker tag ucnrs-rams:v1.0.0 YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/ucnrs-rams:v1.0.0
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/ucnrs-rams:v1.0.0

# Or use the deploy script
./scripts/docker-deploy.sh deploy-ecr v1.0.0 us-west-2 YOUR_ACCOUNT_ID
```

## Why This Change?

### Before
- `Dockerfile.production` was misleading when used for development preview or staging
- Implied the file was only for production environments
- Conflicted with Docker/Docker Compose best practices

### After
- `Dockerfile.server` clearly indicates it's for server deployments (any remote environment)
- `docker-compose.server.yml` matches the Dockerfile naming
- Aligns with industry standard conventions
- Leaves room for environment-specific overrides if needed (e.g., `docker-compose.server.staging.yml`)

## Compatibility

This is a **breaking change** for:
- CI/CD pipelines that reference `Dockerfile.production` or `docker-compose.production.yml`
- Local scripts that reference the old filenames
- Team members with custom documentation

### Migration Steps

If you have scripts or CI/CD pipelines using the old names:

1. Update file references from `Dockerfile.production` to `Dockerfile.server`
2. Update file references from `docker-compose.production.yml` to `docker-compose.server.yml`
3. Test locally with the new compose file
4. Update your CI/CD configuration (GitHub Actions, etc.)
5. Update any local scripts that reference these files

### Example Updates

```bash
# Old commands
docker build -f Dockerfile.production -t ucnrs-rams:latest .
docker-compose -f docker-compose.production.yml up

# New commands
docker build -f Dockerfile.server -t ucnrs-rams:latest .
docker-compose -f docker-compose.server.yml up
```

## Related Documentation

- `DOCKERFILE_NAMING_RATIONALE.md` - Detailed explanation of naming decisions
- `DEPLOYMENT.md` - Comprehensive deployment guide for all environments
- `PRODUCTION_DOCKERFILE_SUMMARY.md` - Technical details of the server Dockerfile
- `README.md` - Main project documentation

## Questions?

For more information about the Docker configuration, see:
- `DEPLOYMENT.md` for deployment instructions
- `DOCKERFILE_NAMING_RATIONALE.md` for the rationale behind naming choices
- `scripts/docker-deploy.sh` for automated build and deployment helper

