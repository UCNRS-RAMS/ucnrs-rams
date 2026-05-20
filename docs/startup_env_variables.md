SsmPath/RdsName
SsmPath/RdsUsername
SsmPath/RdsHost
SsmPath/RdsPort
SsmPath/RdsPassword
SsmPath/RailsMasterKey
SsmPath/secret_key_base
SsmPath/s3_access_key
SsmPath/s3_secret_key

---
secrets
---
DATABASE_PASSWORD -> ssm:${SsmPath}/RdsPassword
RAILS_MASTER_KEY -> ssm:${SsmPath}/RailsMasterKey
SECRET_KEY_BASE -> ssm:${SsmPath}/secret_key_base
AWS_ACCESS_KEY -> ssm:${SsmPath}/s3_access_key
AWS_SECRET_KEY -> ssm:${SsmPath}/s3_secret_key

---
Environment
---
DATABASE_HOST -> ssm:${SsmPath}/RdsHost
DATABASE_PORT -> ssm:${SsmPath}/RdsPort
DATABASE_NAME -> ssm:${SsmPath}/RdsName
DATABASE_USERNAME -> ssm:${SsmPath}/RdsUsername

RAILS_ENV -> !Ref RailsEnv (from sceptre config)
HOST -? > !Ref Host (from sceptre config)
PROTOCOL -> !Ref Protocol (from sceptre config)
MAILER_HOST -> !Ref Host (from sceptre config) * this may be wrong
MAILER_PROTOCOL -> !Ref Protocol (from sceptre config) * this may be wrong
PORT -> !Sub "${ContainerPort}"
FORCE_SSL -> !Ref ForceSsl (from sceptre config)
WEB_CONCURRENCY -> !Ref WebConcurrency (from sceptre config)
RAILS_MAX_THREADS -> !Ref RailsMaxThreads (from sceptre config)
RAILS_MIN_THREADS -> !Ref RailsMinThreads (from sceptre config)
RAILS_LOG_TO_STDOUT -> !Ref RailsLogToStdout (from sceptre config
RAILS_SERVE_STATIC_FILES -> !Ref RailsServeStaticFiles (from sceptre config)
ACTIVE_STORAGE_BUCKET -> !Ref UploadsBucketName (from sceptre config)

RAILS is served like production in all environments on servers, but just has different values for things like database, etc.

# Set production environment
ENV RAILS_ENV=production \
RAILS_LOG_TO_STDOUT=true \
RAILS_SERVE_STATIC_FILES=true

SMTP_HOST=localhost
SMTP_PORT=587
SMTP_USERNAME=emailuser
SMTP_PASSWORD=12345
SMTP_DOMAIN=localhost