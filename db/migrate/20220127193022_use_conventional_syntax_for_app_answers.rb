class UseConventionalSyntaxForAppAnswers < ActiveRecord::Migration[6.1]
  def change
    rename_table :AppAnswers, :project_reserve_answers
    rename_column :project_reserve_answers, :AppAnswerID, :id
    rename_column :project_reserve_answers, :ResQuestionID, :reserve_question_id
    rename_column :project_reserve_answers, :BooleanAnswer, :boolean_answer
    rename_column :project_reserve_answers, :TextAnswer, :text_answer
  end
end
