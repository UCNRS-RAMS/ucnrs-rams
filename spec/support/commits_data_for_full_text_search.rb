# frozen_string_literal: true

# MySQL's InnoDB FULLTEXT indexes (used by `Ror.search`, via `rors.searchable_text`)
# only become visible once a transaction commits - even to the same connection that
# inserted the row, inside its own still-open transaction. RSpec's default
# `use_transactional_tests` wraps every example in a transaction that is rolled back
# at the end, so a spec that creates a Ror and immediately searches for it within the
# same example would never see a match.
#
# Example groups that need to create-then-search in one example can call
# `commits_data_for_full_text_search!` to disable that per-example transaction. Since
# the created records are then genuinely committed, this also restores every tracked
# table to its pre-example contents (and AUTO_INCREMENT counter) afterward so later
# specs - including ID-sensitive seed specs - are unaffected.
module CommitsDataForFullTextSearch
  # Institutions reference countries/states, so they're deleted first.
  TRACKED_TABLES = %w[institutions rors countries states].freeze

  def commits_data_for_full_text_search!
    self.use_transactional_tests = false

    around do |example|
      connection = ActiveRecord::Base.connection
      snapshot = CommitsDataForFullTextSearch::TRACKED_TABLES.index_with do |table|
        {
          ids: connection.select_values("SELECT id FROM #{table}"),
          auto_increment: connection.select_value(
            "SELECT AUTO_INCREMENT FROM information_schema.tables " \
            "WHERE table_schema = DATABASE() AND table_name = #{connection.quote(table)}"
          )
        }
      end

      example.run
    ensure
      connection = ActiveRecord::Base.connection
      CommitsDataForFullTextSearch::TRACKED_TABLES.each do |table|
        kept_ids = snapshot[table][:ids]
        if kept_ids.present?
          connection.execute("DELETE FROM #{table} WHERE id NOT IN (#{kept_ids.join(',')})")
        else
          connection.execute("DELETE FROM #{table}")
        end
        connection.execute("ALTER TABLE #{table} AUTO_INCREMENT = #{snapshot[table][:auto_increment]}")
      end
    end
  end
end

RSpec.configure do |config|
  config.extend CommitsDataForFullTextSearch
end
