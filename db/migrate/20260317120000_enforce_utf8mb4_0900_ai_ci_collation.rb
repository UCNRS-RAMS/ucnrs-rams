class EnforceUtf8mb40900AiCiCollation < ActiveRecord::Migration[7.0]
  TARGET_CHARSET = "utf8mb4".freeze
  TARGET_COLLATION = "utf8mb4_0900_ai_ci".freeze
  TEXTUAL_DATA_TYPES = %w[char varchar tinytext text mediumtext longtext enum set].freeze

  def up
    table_rows.each do |row|
      table_name = row_value(row, "table_name")
      table_collation = row_value(row, "table_collation")

      if table_requires_column_conversion?(table_name)
        say "Converting #{table_name} columns to #{TARGET_CHARSET}/#{TARGET_COLLATION}"
        execute <<~SQL
          ALTER TABLE #{connection.quote_table_name(table_name)}
          CONVERT TO CHARACTER SET #{TARGET_CHARSET}
          COLLATE #{TARGET_COLLATION}
        SQL
      elsif !target_collation?(table_collation)
        say "Updating default charset/collation for #{table_name}"
        execute <<~SQL
          ALTER TABLE #{connection.quote_table_name(table_name)}
          DEFAULT CHARACTER SET #{TARGET_CHARSET}
          COLLATE #{TARGET_COLLATION}
        SQL
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration intentionally has no down path"
  end

  private

  def table_rows
    connection.select_all(<<~SQL)
      SELECT table_name, table_collation
      FROM information_schema.tables
      WHERE table_schema = #{connection.quote(connection.current_database)}
        AND table_type = 'BASE TABLE'
      ORDER BY table_name
    SQL
  end

  def table_requires_column_conversion?(table_name)
    connection.select_value(<<~SQL).present?
      SELECT 1
      FROM information_schema.columns
      WHERE table_schema = #{connection.quote(connection.current_database)}
        AND table_name = #{connection.quote(table_name)}
        AND data_type IN (#{quoted_textual_types})
        AND (
          character_set_name <> #{connection.quote(TARGET_CHARSET)}
          OR collation_name <> #{connection.quote(TARGET_COLLATION)}
        )
      LIMIT 1
    SQL
  end

  def quoted_textual_types
    TEXTUAL_DATA_TYPES.map { |type| connection.quote(type) }.join(", ")
  end

  def target_collation?(collation)
    collation.to_s.casecmp(TARGET_COLLATION).zero?
  end

  def row_value(row, key)
    row[key] || row[key.to_sym] || row[key.upcase] || row[key.upcase.to_sym] ||
      raise(KeyError, "Missing #{key.inspect} in row keys: #{row.keys.inspect}")
  end
end

