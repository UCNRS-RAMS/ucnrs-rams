class UpdateReserveQuestionsInvolves < ActiveRecord::Migration[6.1]
  def change
    rename_column :reserve_questions, :involves_plants_fungus_soil, :involves_plants_fungi_soil
  end
end
