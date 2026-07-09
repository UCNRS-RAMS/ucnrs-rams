# rubocop:disable Metrics/BlockLength
namespace :ops do

  desc "Fixes the format of ORCID identifiers in the database. " \
       "Modes: dry_run (default) copies users to users_copy-<timestamp> and updates the copy; " \
       "real_run updates the users table directly. " \
       'Usage: bin/rails "ops:fix-orcid-format[dry_run]" or bin/rails "ops:fix-orcid-format[real_run]"'
  task :"fix-orcid-format", [:mode] => :environment do |_t, args|
    args.with_defaults(mode: "dry_run")

    mode = args[:mode].to_s.downcase.strip
    unless %w[dry_run real_run].include?(mode)
      raise ArgumentError, "Invalid mode '#{args[:mode]}'. Use 'dry_run' or 'real_run'."
    end

    target_table = if mode == "real_run"
                     "users"
                   else
                     "users_copy-#{Time.current.strftime('%Y-%m-%d-%H%M%S')}"
                   end

    connection = ActiveRecord::Base.connection

    if mode == "dry_run"
      puts "Dry run mode: copying users to `#{target_table}`..."
      connection.execute("DROP TABLE IF EXISTS `#{target_table}`")
      connection.execute("CREATE TABLE `#{target_table}` LIKE users")
      connection.execute("INSERT INTO `#{target_table}` SELECT * FROM users")
    else
      puts "Real run mode: updating `users` table directly..."
    end

    cleanup_queries = [
      [
        "Setting placeholder ORCID values to NULL",
        <<~SQL
          UPDATE `#{target_table}`
          SET orcid = NULL
          WHERE NULLIF(TRIM(orcid), '') IS NOT NULL
            AND LOWER(TRIM(orcid)) IN ('none', 'n/a', 'na', 'not applicable', 'unsure', '-', 'no', '???');
        SQL
      ],
      [
        "Stripping ORCID URL prefixes",
        <<~SQL
          UPDATE `#{target_table}`
          SET orcid = UPPER(REGEXP_REPLACE(
            TRIM(orcid),
            '^(?:https?://)?(?:www[.])?orcid[.]org/|/$',
            ''
          ))
          WHERE NULLIF(TRIM(orcid), '') IS NOT NULL
            AND REGEXP_LIKE(
              TRIM(orcid),
              '^(?:(?:https?://)?(?:www[.])?orcid[.]org/)?[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9Xx]/?$'
            );
        SQL
      ],
      [
        "Stripping ORCID URL prefixes with a space before the identifier",
        <<~SQL
          UPDATE `#{target_table}`
          SET orcid = REGEXP_REPLACE(
            TRIM(orcid),
            '^[[:space:]]*(?:(?:https?://)?(?:www[.])?orcid[.]org/[[:space:]]+)([0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9Xx]|[0-9]{4} [0-9]{4} [0-9]{4} [0-9]{3}[0-9Xx]|[0-9]{15}[0-9Xx])[[:space:]]*$',
            '$1'
          )
          WHERE NULLIF(TRIM(orcid), '') IS NOT NULL
            AND REGEXP_LIKE(
              TRIM(orcid),
              '^[[:space:]]*(?:(?:https?://)?(?:www[.])?orcid[.]org/[[:space:]]+)([0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9Xx]|[0-9]{4} [0-9]{4} [0-9]{4} [0-9]{3}[0-9Xx]|[0-9]{15}[0-9Xx])[[:space:]]*$'
            );
        SQL
      ],
      [
        "Removing 'ORCID: ' prefix",
        <<~SQL
          UPDATE `#{target_table}`
          SET orcid = REGEXP_REPLACE(TRIM(orcid), '^ORCID:[[:space:]]*', '')
          WHERE NULLIF(TRIM(orcid), '') IS NOT NULL
            AND REGEXP_LIKE(
              TRIM(orcid),
              '^ORCID:[[:space:]]*([0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9Xx]|[0-9]{4} [0-9]{4} [0-9]{4} [0-9]{3}[0-9Xx]|[0-9]{15}[0-9Xx])$'
            );
        SQL
      ],
      [
        "Converting space-separated ORCIDs to dashed format",
        <<~SQL
          UPDATE `#{target_table}`
          SET orcid = REPLACE(TRIM(orcid), ' ', '-')
          WHERE NULLIF(TRIM(orcid), '') IS NOT NULL
            AND REGEXP_LIKE(
              TRIM(orcid),
              '^[0-9]{4} [0-9]{4} [0-9]{4} [0-9]{3}[0-9Xx]$'
            );
        SQL
      ],
      [
        "Converting 16-digit ORCIDs to dashed format",
        <<~SQL
          UPDATE `#{target_table}`
          SET orcid = CONCAT(
            SUBSTRING(TRIM(orcid), 1, 4), '-',
            SUBSTRING(TRIM(orcid), 5, 4), '-',
            SUBSTRING(TRIM(orcid), 9, 4), '-',
            SUBSTRING(TRIM(orcid), 13, 4)
          )
          WHERE NULLIF(TRIM(orcid), '') IS NOT NULL
            AND REGEXP_LIKE(
              TRIM(orcid),
              '^[0-9]{15}[0-9Xx]$'
            );
        SQL
      ]
    ]

    cleanup_queries.each do |description, sql|
      affected_rows = connection.update(sql)
      puts "#{description}: updated #{affected_rows} row(s) in `#{target_table}`."
    end

    puts <<~SQL

        To examine items not in correct orcid format and fix manually:

        SELECT id, orcid, first_name, middle_name, last_name, email
        FROM `#{target_table}`
        WHERE NULLIF(TRIM(orcid), '') IS NOT NULL
          AND NOT REGEXP_LIKE(
            orcid,
            '^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9Xx]$'
          );

        OR to see all the items in the correct format in the database:

        SELECT id, orcid, first_name, middle_name, last_name, email
        FROM `#{target_table}`
        WHERE NULLIF(TRIM(orcid), '') IS NOT NULL
          AND REGEXP_LIKE(
            orcid,
            '^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9Xx]$'
          );
    SQL
  end
end
# rubocop:enable Metrics/BlockLength
