class Permit < ApplicationRecord
  belongs_to :state, optional: true

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

  def self.visible
    where(visible: true)
  end

  def self.matching_project_type(project_type)
    where("(LOWER(?) = 'Research' AND permits.research = 1)", [project_type])
      .or(where("(LOWER(?) = LOWER('Class') AND permits.university_class = 1)", [project_type]))
      .or(where("(LOWER(?) = LOWER('Meeting') AND permits.conference = 1)", [project_type]))
      .or(where("(LOWER(?) = LOWER('Public Use') AND permits.public = 1)", [project_type]))
      .or(where("(LOWER(?) = LOWER('Housing') AND permits.housing = 1)", [project_type]))
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
end
