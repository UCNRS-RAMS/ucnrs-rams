class BackfillInvolvesAllOnUntaggedReserveQuestions < ActiveRecord::Migration[8.1]
  def up
    execute(<<~SQL.squish)
      UPDATE reserve_questions
      SET involves_all = TRUE
      WHERE involves_mammals IS NOT TRUE
        AND involves_reptiles IS NOT TRUE
        AND involves_amphibians IS NOT TRUE
        AND involves_fish IS NOT TRUE
        AND involves_birds IS NOT TRUE
        AND involves_plants_fungi_soil IS NOT TRUE
        AND threatened_endangered_flag IS NOT TRUE
        AND involves_all IS NOT TRUE
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
