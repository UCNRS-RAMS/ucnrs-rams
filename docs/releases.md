# Releases and deployment

RAMS follows the same release-please workflow as FAIRStation: changes merge into
`main`, release-please maintains a release PR, and merging that PR publishes a
GitHub release and `vX.Y.Z` tag. Each published stable release automatically opens
a deployment issue using [the release checklist](../.github/ISSUE_TEMPLATE/release.md).
The issue connects that exact source version to the manual production deployment
documented in the [production server runbook](https://github.com/CDLUC3/ngrams-doc/blob/main/doc/production_server.md).

## Initial GitHub setup

1. Add a fine-grained PAT scoped to `UCNRS-RAMS/ucnrs-rams`, with **Contents**,
   **Issues**, and **Pull requests** read/write, as the Actions secret
   `RELEASE_PLEASE_TOKEN`. Have the organization approve the token if required,
   and arrange renewal before it expires. This is a tooling secret, not a Rails
   credential.
2. Allow GitHub Actions and the actions used by the two workflows. The release
   workflow uses the PAT; the checklist workflow uses `GITHUB_TOKEN` with
   `contents: read` and `issues: write`.
3. Keep CI and review requirements on `main`, including generated release PRs.
   Use squash merges and [Conventional Commit PR titles](git_conventions.md).
4. Merge this configuration, then merge a releasable PR to start the release PR.

The dedicated token is required because events created with `GITHUB_TOKEN` do
not normally trigger other Actions workflows. In particular, publishing the
release must trigger `deployment-checklist.yml`. See the
[release-please action documentation](https://github.com/googleapis/release-please-action#github-credentials).

Version tracking starts at the existing `v3.4.0` tag. The manifest and
`version.txt` contain `3.4.0`; `bootstrap-sha` identifies that tag's commit as the
fallback history boundary when no prior GitHub release is found. Subsequent
releases use their own release boundaries. Release PRs update these version
files and create/update `CHANGELOG.md`. The private JavaScript package version
is not the application release version.

## Routine release

1. Squash-merge feature and fix PRs into `main`. `feat:` produces a minor bump,
   `fix:` a patch bump, and breaking changes (`!` or `BREAKING CHANGE:`) a major
   bump. Other conventional types can appear in release notes, but do not by
   themselves necessarily start a release. Unstructured commit subjects may be
   omitted; review the release notes for completeness.
2. Review the release PR's version and changelog as it accumulates changes.
   Wait for CI and the normal review requirements, then squash-merge it when
   ready to release. Do not manually tag the same version.
3. Release-please publishes the GitHub release and tag. The deployment checklist
   workflow opens a `Deploy RAMS vX.Y.Z` issue containing the release URL and
   resolved source commit. Reruns preserve existing issues, including closed
   issues and checked boxes.
4. Assign a deployment owner and complete the issue for each affected environment.
   Record the source SHA, previously deployed tag, migration and restart results,
   verification results, and rollback plan. UC Nature validates operational
   readiness.

To retry release reconciliation after a transient failure:

```sh
gh workflow run release-please.yml --ref main
```

To retry creating a missing deployment issue for an already published release:

```sh
gh workflow run deployment-checklist.yml --ref main -f tag=v3.4.1
```

The checklist template must exist in that release's source tree. The workflow
does not create checklists for draft or prerelease releases.

## Production deployment handoff

The [production server runbook](https://github.com/CDLUC3/ngrams-doc/blob/main/doc/production_server.md)
identifies production as a Mac Studio at Riverside, serving
<https://rams.ucnature.org/>. Deployment uses SSH to `tyson.ucnature.org`, the
`infomgr` account, and a tagged checkout in `~/Sites/ucnrs-rams`. Arrange SSH
access with the server owner as described in that runbook.

Publishing a GitHub release opens the deployment tracking issue. The deployment
owner then follows the server procedure below; the GitHub workflows do not
connect to production or run migrations.

Before changing the checkout, record the currently deployed tag and full commit
SHA in the issue. Confirm CI passes for the new release commit, review migration
compatibility, and record the database backup and rollback plan. Review any new
settings or secrets in `~/.zprofile` as the upstream runbook describes, and ensure
the Ruby version in the release's `.ruby-version` is available.

Connect and switch to the application account:

```sh
ssh <username>@tyson.ucnature.org
sudo -i -u infomgr
cd ~/Sites/ucnrs-rams
```

Deploy the published tag, substituting the actual release version:

```sh
git status --short  # resolve any local changes before proceeding
git describe --tags --exact-match  # record the previous tag, if present
git rev-parse HEAD                 # record the previous source SHA
git fetch origin --tags
git checkout --detach v3.4.1       # replace with the published release tag
git rev-parse HEAD                 # must match the source SHA in the release issue

export RAILS_ENV=production
bundle install
bundle exec rails db:migrate
nvm use
yarn install --frozen-lockfile
bundle exec rails assets:precompile
touch tmp/restart.txt
```

Run these commands in order and stop if any command fails. The frozen Yarn
install uses the committed lockfile with Yarn Classic. `touch tmp/restart.txt`
is the application's restart request used by the existing server procedure.
Verify <https://rams.ucnature.org/up>, sign-in, and changed user workflows, then
check application logs and Honeybadger. Record the deployed SHA and verification
results before closing the issue.

For rollback, check out the previously verified tag or SHA, install its
dependencies, precompile its assets, and request the restart using the same
procedure. Confirm schema compatibility first: changing the checkout does not
undo migrations. Document any data recovery or forward fix needed for
incompatible migrations rather than blindly reversing database changes.

## Docker and AWS environments

[The Docker documentation](docker.md) describes server image builds and a
separate AWS CodePipeline/CodeBuild → ECR → ECS deployment design. Those steps
are separate from the production Mac Studio procedure above. Their configuration
and environment ownership must be confirmed before using them for a deployment.
`config/deploy.yml` is a Kamal scaffold, and `scripts/docker-deploy.sh` is an
untested example with its push/deploy commands disabled.
