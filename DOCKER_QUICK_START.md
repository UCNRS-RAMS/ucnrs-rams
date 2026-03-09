# Docker Configuration Refactoring - Quick Start

## TL;DR

✅ **What Changed**: `Dockerfile.production` → `Dockerfile.server` and `docker-compose.production.yml` → `docker-compose.server.yml`

✅ **Why**: More accurate naming - these files are used for ALL server deployments (dev preview, staging, production), not just production

✅ **Status**: Complete and verified (33/33 checks passed)

## For Developers

### Local Development (No Changes)
```bash
docker-compose -f docker-compose.yml up
```

### Test Server Image
```bash
# Build
docker build -f Dockerfile.server -t ucnrs-rams:latest .

# Test with compose
docker-compose -f docker-compose.server.yml up
```

### Build for Deployment
```bash
docker build -f Dockerfile.server -t ucnrs-rams:v1.0.0 .
```

## For DevOps/Deployment

### AWS Deployment (ECS/ECR)
```bash
# Authenticate
aws ecr get-login-password --region us-west-2 | \
  docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com

# Tag & Push
docker tag ucnrs-rams:v1.0.0 YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/ucnrs-rams:v1.0.0
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/ucnrs-rams:v1.0.0
```

### Or Use Deploy Script
```bash
./scripts/docker-deploy.sh deploy-ecr v1.0.0 us-west-2 YOUR_ACCOUNT_ID
```

## Files to Update in Your CI/CD

### GitHub Actions Example
```yaml
- name: Build server image
  run: |
    docker build -f Dockerfile.server -t ucnrs-rams:latest .
    # (was: docker build -f Dockerfile.production ...)

- name: Test with docker-compose
  run: |
    docker-compose -f docker-compose.server.yml up -d
    # (was: docker-compose -f docker-compose.production.yml ...)
```

### GitLab CI Example
```yaml
build:
  script:
    - docker build -f Dockerfile.server -t ucnrs-rams:latest .
    # (was: docker build -f Dockerfile.production ...)
```

## Updated Files

These files reference the new names:
- ✅ `docker-compose.server.yml`
- ✅ `DEPLOYMENT.md`
- ✅ `PRODUCTION_DOCKERFILE_SUMMARY.md`
- ✅ `scripts/docker-deploy.sh`

## Documentation

**Quick Guides:**
- 📖 `DOCKERFILE_NAMING_RATIONALE.md` - Why we renamed these files
- 📖 `DOCKER_REFACTORING_SUMMARY.md` - Overview, examples, migration steps
- 📖 `REFACTORING_COMPLETION_REPORT.md` - Detailed report with verification

**Reference:**
- 📖 `DEPLOYMENT.md` - Deployment procedures and examples
- 📖 `PRODUCTION_DOCKERFILE_SUMMARY.md` - Technical Dockerfile details

## Verify Installation

```bash
./verify-docker-refactoring.sh
```

Expected result: `Passed: 33 ✓ Failed: 0 ✗`

## What's Not Changing

- Local development workflow (`docker-compose.yml`)
- Dockerfile functionality (same as before)
- Environment variable requirements
- Deployment procedures
- Application behavior

## Questions?

1. **Why was it renamed?** → Read `DOCKERFILE_NAMING_RATIONALE.md`
2. **How do I migrate?** → Read `DOCKER_REFACTORING_SUMMARY.md`
3. **How do I deploy?** → Read `DEPLOYMENT.md`
4. **What changed exactly?** → Read `REFACTORING_COMPLETION_REPORT.md`

## Checklist for Your Team

- [ ] Review `DOCKER_REFACTORING_SUMMARY.md`
- [ ] Update CI/CD pipelines (replace `Dockerfile.production` with `Dockerfile.server`)
- [ ] Update any local scripts/aliases
- [ ] Test locally: `docker build -f Dockerfile.server ...`
- [ ] Test locally: `docker-compose -f docker-compose.server.yml up`
- [ ] Deploy to dev preview/staging for testing
- [ ] Update team documentation
- [ ] Deploy to production with confidence! 🚀

---

**Status**: ✅ Ready for Production
**Verified**: 33/33 checks passed
**Breaking Change**: Yes - update file references

