class Permit < ApplicationRecord
  FLAG_TYPE_COLUMN_MAP = {
    "iacuc_flag" => :iacuc,
    "drone_flag" => :drone_flag,
    "scuba_flag" => :scuba_flag,
  }.freeze

  belongs_to :state, optional: true
  has_many :project_permit_answers
  has_many :projects, through: :project_permit_answers
  has_many :reserve_permits
  has_many :reserves, through: :reserve_permits

  enum location: {
    visit: "visit",
    project: "project",
  }

  enum authority: {
    federal: "Federal",
    state: "State",
    local: "Local",
    institution: "Institution",
  }

  def self.in_order
    order(:authority, :sort_order)
  end

  def self.for_projects
    where(location: "project")
  end

  def self.for_visits
    where(location: "visit")
  end

  def self.visible
    where(visible: true)
  end

  def self.matching_project_type(project_type)
    where(
        "(LOWER(?) = LOWER('Research') AND permits.research = 1)",
        [Project.project_types[project_type.downcase]]
      )
      .or(where(
        "(LOWER(?) = LOWER('Class') AND permits.university_class = 1)",
        [Project.project_types[project_type.downcase]]
      ))
      .or(where(
        "(LOWER(?) = LOWER('Meeting') AND permits.conference = 1)",
        [Project.project_types[project_type.downcase]]
      ))
      .or(where(
        "(LOWER(?) = LOWER('Public Use') AND permits.public = 1)",
        [Project.project_types[project_type.downcase]]
      ))
      .or(where(
        "(LOWER(?) = LOWER('Housing') AND permits.housing = 1)",
        [Project.project_types[project_type.downcase]]
      ))
  end

  def self.involving_related(project)
    where("involves_all")
      .or(where("(? AND involves_mammals)", [project.involves_mammals]))
      .or(where("(? AND involves_reptiles)", [project.involves_reptiles]))
      .or(where("(? AND involves_amphibians)", [project.involves_amphibians]))
      .or(where("(? AND involves_fish)", [project.involves_fish]))
      .or(where("(? AND involves_birds)", [project.involves_birds]))
      .or(where("(? AND involves_plants_fungi_soil)", [project.involves_plants_fungi_soil]))
      .or(where("(? AND threatened_endangered_flag)", [project.involves_threatened_endangered_species]))
  end

  def self.include_answers_for(project)
    select(
      Permit.arel_table[Arel.star],
      ProjectPermitAnswer.arel_table[:answer],
      ProjectPermitAnswer.arel_table[:id].as("answer_id"),
    )
      .joins(<<~end_sql)
        LEFT OUTER JOIN project_permit_answers
        ON permits.id = project_permit_answers.permit_id
        AND project_permit_answers.project_id = #{project.id.to_i}
      end_sql
  end

  def self.of_iacuc_type
    where(iacuc: true)
  end

  def self.with_flag_type(flag_type)
    if FLAG_TYPE_COLUMN_MAP[flag_type.downcase]
      where(FLAG_TYPE_COLUMN_MAP[flag_type.downcase] => true)
    else
      none
    end
  end
end
