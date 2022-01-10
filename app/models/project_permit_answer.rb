class ProjectPermitAnswer < ApplicationRecord
  belongs_to :project
  belongs_to :permit

  validates :answer, inclusion: [true, false]
end
