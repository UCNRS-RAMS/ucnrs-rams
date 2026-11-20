### Overview of Release

### Service(s)
-

### Github Issue Link(s)
-

### Environments Affected
-

### Source Code
Link(s) to tagged release(s)

### Source Code Tag
-

### Deployment Steps
- [ ] Record the deployment owner, target environment, release tag, source commit, and currently deployed tag for rollback.
- [ ] Confirm CI passes for the tagged commit and UC Nature approves operational readiness.
- [ ] Review database migrations, configuration, and infrastructure changes; record backup and rollback plans.
- [ ] SSH to `tyson.ucnature.org`, switch to `infomgr`, and enter `~/Sites/ucnrs-rams`.
- [ ] Fetch tags, check out the published release tag, and confirm `git rev-parse HEAD` matches the release source commit.
- [ ] Set `RAILS_ENV=production`; apply required environment changes and confirm the Ruby version in `.ruby-version` is available.
- [ ] Run `bundle install`, `bundle exec rails db:migrate`, `nvm use`, `yarn install --frozen-lockfile`, and `bundle exec rails assets:precompile` as described in the runbook.
- [ ] Run `touch tmp/restart.txt` to request the application restart.
- [ ] Verify `https://rams.ucnature.org/up`, sign-in, and the affected workflows; check logs and Honeybadger.
- [ ] Record the result and environment below, then close this issue when deployment is verified.

Previously deployed tag / deployed source SHA / migration and restart results:
-

Deployment result:
-

### Infrastructure Changes
(Server configuration, environment variables, database, etc.)

### Documentation Link
- [Release and deployment runbook](https://github.com/UCNRS-RAMS/ucnrs-rams/blob/main/docs/releases.md)
- [Production server runbook](https://github.com/CDLUC3/ngrams-doc/blob/main/doc/production_server.md)

### Rollback Instructions
-
