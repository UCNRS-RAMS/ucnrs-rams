class ReserveQuestion < ApplicationRecord
  validates :question_type, presence: true
  validates :answer_required, inclusion: [true, false]
  validates :public_use, inclusion: [true, false]
  validates :university_class, inclusion: [true, false]
  validates :research, inclusion: [true, false]
  validates :housing, inclusion: [true, false]
  validates :conference, inclusion: [true, false]

  belongs_to :reserve
  has_many :project_reserve_answers

  enum location: {
    visit: "visit",
    project: "project",
  }

  enum question_type: {
    boolean: "Boolean",
    text: "Text",
  }

  def reserve_name
    reserve.name
  end
end
