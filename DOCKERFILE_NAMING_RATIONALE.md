# Dockerfile Naming Convention Rationale

## Overview

This document explains the naming convention used for the Docker files in this project and the rationale behind the choices.

## File Naming Changes

| Old Name | New Name | Purpose |
|----------|----------|---------|
| `Dockerfile` | `Dockerfile` | Local development environment (unchanged) |
| `Dockerfile.production` | `Dockerfile.server` | Server deployment (development preview, staging, production) |
| `docker-compose.production.yml` | `docker-compose.server.yml` | Compose configuration for server environments (unchanged filename intent) |

## Rationale

### Why "Dockerfile.server" Instead of "Dockerfile.production"?

The original naming was confusing because `Dockerfile.production` was used for:
- **Development preview** servers (for developers and stakeholders to test)
- **Staging** servers (for QA and product manager testing)
- **Production** servers (live customer-facing environment)

Since the same Dockerfile is used across all remote server environments (not just production), naming it `Dockerfile.production` was misleading. The `.server` suffix more accurately reflects that this is the Dockerfile for any remote server deployment, regardless of the environment.

### Why "docker-compose.server.yml" Instead of "docker-compose.production.yml"?

For the same reasons as above. This Docker Compose file is used to test the server image locally before deploying to remote servers, regardless of which environment (dev preview, staging, or production) the image will eventually run in.

## Environment-Specific Configuration

While the Dockerfile is the same, environment-specific configuration is handled through:

1. **Environment Variables** (`.env` files or AWS Secrets Manager)
   - `RAILS_ENV` is always `production` for the server image
   - Other variables (database host, API endpoints, feature flags, etc.) vary by environment

2. **Docker Compose Override Files** (Recommended future approach)
   ```bash
   # Local development
   docker-compose -f docker-compose.yml up

   # Development preview server testing locally
   docker-compose -f docker-compose.yml -f docker-compose.server.yml up

   # Staging-specific testing locally
   docker-compose -f docker-compose.yml -f docker-compose.server.staging.yml up
   ```

3. **Container Orchestration** (ECS, Kubernetes)
   - Different environment configurations at deployment time
   - Secrets injected from AWS Secrets Manager or Kubernetes Secrets

## Best Practices Applied

This naming convention follows Docker and Docker Compose best practices:

1. **Clarity**: File names clearly indicate their purpose
2. **Consistency**: Development vs. Server is immediately obvious
3. **Flexibility**: Easy to extend (e.g., `docker-compose.server.staging.yml`)
4. **Standards**: Aligns with industry best practices

## References

- [Docker Compose Documentation - Multiple Compose Files](https://docs.docker.com/compose/multiple-compose-files/)
- [12 Factor App - Dev/Prod Parity](https://12factor.net/dev-prod-parity)

## Related Files

- `DEPLOYMENT.md` - Comprehensive deployment guide
- `PRODUCTION_DOCKERFILE_SUMMARY.md` - Technical details of server Dockerfile features
- `Dockerfile.server` - The server deployment Dockerfile
- `docker-compose.server.yml` - The server Docker Compose configuration
- `scripts/docker-deploy.sh` - Helper script for building and deploying the server image

