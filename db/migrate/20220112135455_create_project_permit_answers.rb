class CreateProjectPermitAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :project_permit_answers do |t|
      t.references :project, type: :integer, unsigned: true, null: false, foreign_key: true
      t.references :permit, type: :integer, unsigned: true, null: false, foreign_key: true
      t.boolean :answer, null: false

      t.timestamps
    end
  end
end
