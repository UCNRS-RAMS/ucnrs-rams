class ChangeTextColumnsToMediumtext < ActiveRecord::Migration[8.1]
  COLUMNS_TO_MIGRATE = {
    reserve_notes: [:note],
    use_policies: %i[description image_url policy_link_text title]
  }.freeze

  def up
    COLUMNS_TO_MIGRATE.each do |table, columns|
      columns.each do |column|
        change_column(table, column, :text, size: :medium) unless mediumtext?(table, column)
      end
    end
  end

  def down
    COLUMNS_TO_MIGRATE.each do |table, columns|
      columns.each do |column|
        change_column(table, column, :text)
      end
    end
  end

  private

  def mediumtext?(table, column)
    column_type = select_value(<<~SQL.squish)
      SELECT COLUMN_TYPE
      FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = '#{table}'
        AND COLUMN_NAME = '#{column}'
    SQL

    column_type.to_s.include?('mediumtext')
  end
end
