class Project < ApplicationRecord
  belongs_to :reserve
  belongs_to :owner, class_name: "User", foreign_key: :user_id
  belongs_to :applicant, class_name: "User"
  has_many :visits

  enum status: {
    open: "Open",
    closed: "Closed",
    incomplete: "Incomplete",
  }

  def self.alphabetized
    order(Arel.sql("SUBSTRING(title, 1, 10)"))
  end

  def visits_count
    visits.count
  end
end
