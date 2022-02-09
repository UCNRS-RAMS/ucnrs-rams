FactoryBot.define do
  factory :project_reserve_answer do
    association :project
    reserve_question do
      question_type = text_answer.present? ? :text : :boolean
      association(
        :reserve_question,
        question_type: question_type,
      )
    end
    boolean_answer { false }
  end
end
