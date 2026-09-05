class AddInvolvesThreatenedEndangeredSpeciesToReserveQuestions < ActiveRecord::Migration[8.1]
  def change
    add_column(
      :reserve_questions,
      :involves_threatened_endangered_species,
      :boolean,
      default: false,
      null: false,
      after: :involves_plants_fungi_soil,
    )
  end
end
