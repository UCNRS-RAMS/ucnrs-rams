class UseConventionalNameForActAnswers < ActiveRecord::Migration[6.1]
  def change
    rename_table :ActAnswers, :visit_reserve_answers
    rename_column :visit_reserve_answers, :ResAnswerID, :id
    rename_column :visit_reserve_answers, :ResQuestionID, :reserve_question_id
    rename_column :visit_reserve_answers, :BooleanAnswer, :boolean_answer
    rename_column :visit_reserve_answers, :TextAnswer, :text_answer

    change_table_comment :visit_reserve_answers, from: nil, to: "renamed from ActAnswers."
  end
end
