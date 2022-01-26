class UseConventionalSyntaxForReserveQuestions < ActiveRecord::Migration[6.1]
  def change
    rename_table :ReserveQuestions, :reserve_questions
    rename_column :reserve_questions, :ResQuestionID, :id
    reversible do |dir|
      dir.up do
        add_column :reserve_questions, :visible, :boolean
        execute("UPDATE reserve_questions SET visible = true WHERE ShowUser = 'Show'")
        execute("UPDATE reserve_questions SET visible = false WHERE ShowUser = 'Hide'")
        remove_column :reserve_questions, :ShowUser
      end
      dir.down do
        add_column :reserve_questions, :ShowUser, "ENUM('Show','Hide')"
        execute("UPDATE reserve_questions SET ShowUser = 'Show' WHERE visible = true")
        execute("UPDATE reserve_questions SET ShowUser = 'Hide' WHERE visible = false")
        remove_column :reserve_questions, :visible
      end
    end
    rename_column :reserve_questions, :QuestionType, :question_type
    rename_column :reserve_questions, :QuestionLocation, :location
    reversible do |dir|
      dir.up do
        execute("ALTER TABLE reserve_questions MODIFY COLUMN location ENUM('Reservation','project','visit')")
        execute("UPDATE reserve_questions SET location = 'visit' WHERE location = 'Reservation'")
        execute("ALTER TABLE reserve_questions MODIFY COLUMN location ENUM('project','visit')")
      end
      dir.down do
        execute("ALTER TABLE reserve_questions MODIFY COLUMN location ENUM('project','visit', 'Reservation')")
        execute("UPDATE reserve_questions SET location = 'Reservation' WHERE location = 'visit'")
        execute("ALTER TABLE reserve_questions MODIFY COLUMN location ENUM('Reservation','project')")
      end
    end
    rename_column :reserve_questions, :Question, :question
    rename_column :reserve_questions, :AdditionalText, :statement
    rename_column :reserve_questions, :SortOrder, :sort_order
    rename_column :reserve_questions, :AnswerRequired, :answer_required
    rename_column :reserve_questions, :public_project, :public
    rename_column :reserve_questions, :class_project, :class
    rename_column :reserve_questions, :research_project, :research
    rename_column :reserve_questions, :housing_only_project, :housing
    rename_column :reserve_questions, :conference_project, :conference

    add_column :reserve_questions, :authority, "ENUM('Federal','State','Local','Institution','Reserve')"
    add_column :reserve_questions, :description, :string
    add_column :reserve_questions, :url_1, :string
    add_column :reserve_questions, :url_link_text_1, :string
    add_column :reserve_questions, :url_2, :string
    add_column :reserve_questions, :url_link_text_2, :string
    add_column :reserve_questions, :url_3, :string
    add_column :reserve_questions, :url_link_text_3, :string
    add_column :reserve_questions, :iacuc_flag, :boolean
    add_column :reserve_questions, :drone_flag, :boolean
    add_column :reserve_questions, :scuba_flag, :boolean
    add_column :reserve_questions, :vertebrate_flag, :boolean
    add_column :reserve_questions, :threatened_endangered_flag, :boolean
    add_column :reserve_questions, :involves_mammals, :boolean
    add_column :reserve_questions, :involves_reptiles, :boolean
    add_column :reserve_questions, :involves_amphibians, :boolean
    add_column :reserve_questions, :involves_fish, :boolean
    add_column :reserve_questions, :involves_birds, :boolean
    add_column :reserve_questions, :involves_plants_fungus_soil, :boolean
    add_column :reserve_questions, :involves_none, :boolean
    add_column :reserve_questions, :involves_all, :boolean
    add_column :reserve_questions, :state_id, :integer
  end
end
