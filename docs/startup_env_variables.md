The variables we need to set for getting the server to run (and where they come from on AWS)

| ENV VARIABLE | AWS Source     | Description                                                                               |
| --- |----------------|-------------------------------------------------------------------------------------------|
| DATABASE_HOST | ssm            | The database host                                                                         |
| DATABASE_PORT | ssm            | The database port                                                                         |
| DATABASE_NAME | ssm            | The database name                                                                         |
| DATABASE_USERNAME | ssm            | The database username                                                                     |
| DATABASE_PASSWORD | ssm            | The database password                                                                     |
| AWS_ACCESS_KEY | ssm            | The AWS access key for S3 bucket                                                          |
| AWS_SECRET_KEY | ssm            | The AWS secret key for S3 bucket                                                          |
| ACTIVE_STORAGE_BUCKET | sceptre config | The name of the S3 bucket for Active Storage uploads                                      |
| RAILS_MASTER_KEY | ssm            | The Rails master key for decrypting credentials (doesn't seem to be used for much)        |
| SECRET_KEY_BASE | ssm            | The Rails secret key base for verifying the integrity of signed cookies and other secrets |
| RAILS_ENV | sceptre config | The Rails environment (production, staging, etc.)                                         |
| HOST | sceptre config | The host for the application (e.g. example.com)                                           |
| PROTOCOL | sceptre config | The protocol for the application (e.g. https)                                             |
| PORT | sceptre config | The port the application listens on (e.g. 3000)                                           |
| FORCE_SSL | sceptre config | Whether to force SSL (true/false)                                                         |
| WEB_CONCURRENCY | sceptre config | The number of web concurrency workers (e.g. 2)                                            |
| RAILS_MAX_THREADS | sceptre config | The maximum number of threads for Rails (e.g. 5) per server                               |
| RAILS_MIN_THREADS | sceptre config | The minimum number of threads for Rails (e.g. 2) per server                               |
| RAILS_LOG_TO_STDOUT | sceptre config | Whether to log to stdout (true/false)                                                     |
| RAILS_SERVE_STATIC_FILES | sceptre config | Whether Rails should serve static files (true/false)                                      |
| SMTP_HOST | ssm            | The SMTP host for sending emails (e.g. localhost)                                         |
| SMTP_PORT | ssm            | The SMTP port for sending emails (e.g. 587)                                               |
| SMTP_USERNAME | ssm            | The SMTP username for sending emails                                                      |
| SMTP_PASSWORD | ssm            | The SMTP password for sending emails                                                      |
| SMTP_DOMAIN | ssm            | The SMTP domain for sending emails (e.g. localhost)                                       |

Note that right now a RAILS_MASTER_KEY is set but it is likely not required
because the SECRET_KEY_BASE is set directly in the environment variables and there are essentially no encrypted credentials being used.
If we were to use encrypted credentials, then the RAILS_MASTER_KEY would be required to decrypt them.

