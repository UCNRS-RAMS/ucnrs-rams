class Visit < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :reserve

  PUBLIC_PROJECT_ID = 0

  validates :purpose_of_visit, presence: true
  validates :project_type, presence: true
  validates :end_date, must_be_after: :start_date
  validates :public_use_category, presence: true, if: :public_use?

  delegate :short_name, to: :reserve, prefix: true

  def self.recent_start_date_first
    order(start_date: :desc)
  end

  enum status: {
    approved: "Approved",
    pending: "Pending approval",
    cancelled: "Cancelled",
    temp: "Temp",
  }

  enum project_type: {
    research: "research",
    university_class: "university class",
    meeting_or_conference: "meeting or conference",
    public_use: "public use",
  }

  enum public_use_category: {
    general_use: "general-use",
    community_event: "community-event",
    fundraiser: "fundraiser",
    k_12_class: "k-12-class",
    private_class: "private-class",
    volunteer: "volunteer",
  }
end
