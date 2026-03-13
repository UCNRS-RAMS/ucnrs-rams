class UpdateUcNrsToUcNature < ActiveRecord::Migration[7.0]
  OLD_CODE_OF_CONDUCT_URL = "https://rams.ucnrs.org/PDF/nrs-codeofconduct.pdf".freeze
  NEW_CODE_OF_CONDUCT_URL = "https://rams.ucnature.org/PDF/nrs-codeofconduct.pdf".freeze

  def up
    execute <<~SQL
      UPDATE reserve_tags
      SET name = 'UC Nature', updated_at = CURRENT_TIMESTAMP
      WHERE category = 'organization' AND name = 'UC NRS'
    SQL

    change_column_default :reserves, :code_of_conduct_url,
      from: OLD_CODE_OF_CONDUCT_URL,
      to: NEW_CODE_OF_CONDUCT_URL

    execute <<~SQL
      UPDATE reserves
      SET code_of_conduct_url = '#{NEW_CODE_OF_CONDUCT_URL}', updated_at = CURRENT_TIMESTAMP
      WHERE code_of_conduct_url LIKE '%rams.ucnrs.org/PDF/nrs-codeofconduct.pdf'
    SQL
  end

  def down
    execute <<~SQL
      UPDATE reserve_tags
      SET name = 'UC NRS', updated_at = CURRENT_TIMESTAMP
      WHERE category = 'organization' AND name = 'UC Nature'
    SQL

    change_column_default :reserves, :code_of_conduct_url,
      from: NEW_CODE_OF_CONDUCT_URL,
      to: OLD_CODE_OF_CONDUCT_URL

    execute <<~SQL
      UPDATE reserves
      SET code_of_conduct_url = '#{OLD_CODE_OF_CONDUCT_URL}', updated_at = CURRENT_TIMESTAMP
      WHERE code_of_conduct_url LIKE '%rams.ucnature.org/PDF/nrs-codeofconduct.pdf'
    SQL
  end
end

