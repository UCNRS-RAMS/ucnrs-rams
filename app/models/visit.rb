class Visit < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :reserve

  delegate :short_name, to: :reserve, prefix: true

  def self.recent_start_date_first
    order(start_date: :desc)
  end

  enum project_type_options: {
    "research" => "research",
    "university class" => "university class",
    "meeting or conference" => "meeting or conference",
    "public use" => "public use",
  }

  enum public_use_categories: {
    "general-use" => "general-use",
    "community-event" => "community-event",
    "fundraiser" => "fundraiser",
    "k-12-class" => "k-12-class",
    "private-class" => "private-class",
    "volunteer" => "volunteer",
  }
end
