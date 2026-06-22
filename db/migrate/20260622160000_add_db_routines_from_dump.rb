class AddDbRoutinesFromDump < ActiveRecord::Migration[8.1]
  ROUTINES_DUMP_PATH = Rails.root.join("db/db_routines.sql")

  def up
    sql_dump = File.read(ROUTINES_DUMP_PATH)

    extract_routine_statements(sql_dump).each do |statement|
      type, name = routine_identity(statement)
      next if routine_exists?(type:, name:)

      execute(statement)
    end
  end

  def down
    # intentionally empty:
    # we cannot safely determine which routines predated this migration, but on newly migrated databases there were
    # none before this unless they were added manually.
  end

  private

  def extract_routine_statements(sql_dump)
    sql_dump
      .scan(/CREATE\s+DEFINER=.*?(?:FUNCTION|PROCEDURE)\s+`[^`]+`.*?;;/mi)
      .map do |raw_statement|
        raw_statement
          .gsub(/CREATE\s+DEFINER=`[^`]+`@`[^`]+`\s+/i, "CREATE ")
          .sub(/;;\s*\z/, ";")
          .strip
      end
  end

  def routine_identity(statement)
    match = statement.match(/\b(FUNCTION|PROCEDURE)\s+`([^`]+)`/i)
    raise "Unable to parse routine name/type from SQL statement" unless match

    [match[1].upcase, match[2]]
  end

  def routine_exists?(type:, name:)
    sql = <<~SQL
      SELECT 1
      FROM information_schema.ROUTINES
      WHERE ROUTINE_SCHEMA = DATABASE()
        AND ROUTINE_TYPE = #{connection.quote(type)}
        AND ROUTINE_NAME = #{connection.quote(name)}
      LIMIT 1
    SQL

    connection.select_value(sql).present?
  end
end

