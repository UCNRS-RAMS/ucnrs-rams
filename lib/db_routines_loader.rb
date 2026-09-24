# frozen_string_literal: true

# Loads missing stored functions and procedures from the frozen db/db_routines.sql
# dump (see the file header for why it must not be edited).
#
# Shared by the AddDbRoutinesFromDump migration and the dev:prime task: databases
# created via db:prepare get schema-loaded, which records routine migrations as
# run without executing them, so nothing else guarantees the routines exist.
class DbRoutinesLoader
  DUMP_PATH = Rails.root.join("db/db_routines.sql")

  def self.load_missing(connection: ActiveRecord::Base.connection)
    new(connection).load_missing
  end

  def initialize(connection)
    @connection = connection
  end

  def load_missing
    extract_routine_statements(File.read(DUMP_PATH)).each do |statement|
      type, name = routine_identity(statement)
      next if routine_exists?(type:, name:)

      @connection.execute(statement)
    end
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

    [ match[1].upcase, match[2] ]
  end

  def routine_exists?(type:, name:)
    sql = <<~SQL
      SELECT 1
      FROM information_schema.ROUTINES
      WHERE ROUTINE_SCHEMA = DATABASE()
        AND ROUTINE_TYPE = #{@connection.quote(type)}
        AND ROUTINE_NAME = #{@connection.quote(name)}
      LIMIT 1
    SQL

    @connection.select_value(sql).present?
  end
end
