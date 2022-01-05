require "rails_helper"

RSpec.describe Permit, type: :model do
  describe "enums" do
    it do
      is_expected.to define_enum_for(:location)
        .with_values(
           visit: "visit",
           project: "project",
        ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:authority)
        .with_values(
          federal: "Federal",
          state: "State",
          local: "Local",
          institution: "Institution",
        ).backed_by_column_of_type(:string)
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:state).optional }
  end

  describe ".in_order" do
    it "sorts by authority and then sort_order" do
      one = create(:permit, authority: :federal, sort_order: 4)
      three = create(:permit, authority: :state, sort_order: 9)
      five = create(:permit, authority: :institution, sort_order: 1)
      four = create(:permit, authority: :local, sort_order: 2)
      two = create(:permit, authority: :state, sort_order: 4)

      results = Permit.in_order

      expect(results).to eq [one, two, three, four, five]
    end
  end

  describe ".for_projects" do
    it "only selects permits with a location of project" do
      project_permit = create(:permit, location: :project)
      visit_permit = create(:permit, location: :visit)

      expect(Permit.for_projects).to eq [project_permit]
    end
  end

  describe ".visible" do
    it "only selects visible permits" do
      showing = create(:permit, visible: true)
      now_showing = create(:permit, visible: false)

      expect(Permit.visible).to eq [showing]
    end
  end

  describe ".matching_project_type" do
    it "uses the project_type string to filter on permit booleans" do
      research_permit = create(:permit, research: true)
      class_permit = create(:permit, university_class: true)
      conference_permit = create(:permit, conference: true)
      public_permit = create(:permit, public: true)
      housing_permit = create(:permit, housing: true)

      expect(Permit.matching_project_type("Research")).to eq [research_permit]
      expect(Permit.matching_project_type("Class")).to eq [class_permit]
      expect(Permit.matching_project_type("Meeting")).to eq [conference_permit]
      expect(Permit.matching_project_type("Public Use")).to eq [public_permit]
      expect(Permit.matching_project_type("Housing")).to eq [housing_permit]
    end
  end

  describe ".involving_related" do
    it "returns the permit if 'involves_all' is set" do
      project = build(:project, involves_fish: true)
      all_permit = create(:permit, involves_all: true, involves_fish: false)
      fish_permit = create(:permit, involves_all: false, involves_fish: true)
      neither_permit = create(:permit, involves_all: false, involves_fish: false)

      expect(Permit.involving_related(project)).to eq [all_permit, fish_permit]
    end

    def project(boolean_key, value = true)
      build(:project, involves_none: false, boolean_key => value)
    end

    it "returns the permit if the involvements match the project's involvements" do
      mammals_permit = create(:permit, involves_mammals: true)
      reptiles_permit = create(:permit, involves_reptiles: true)
      amphibians_permit = create(:permit, involves_amphibians: true)
      fish_permit = create(:permit, involves_fish: true)
      birds_permit = create(:permit, involves_birds: true)
      plants_fungi_soil_permit = create(:permit, involves_plants_fungi_soil: true)
      none_permit = create(:permit, involves_none: true)
      endangered_permit = create(:permit, threatened_endangered_flag: true)

      expect(Permit.involving_related(project(:involves_mammals))).to eq [mammals_permit]
      expect(Permit.involving_related(project(:involves_reptiles))).to eq [reptiles_permit]
      expect(Permit.involving_related(project(:involves_amphibians))).to eq [amphibians_permit]
      expect(Permit.involving_related(project(:involves_fish))).to eq [fish_permit]
      expect(Permit.involving_related(project(:involves_birds))).to eq [birds_permit]
      expect(Permit.involving_related(project(:involves_plants_fungi_soil))).to eq [plants_fungi_soil_permit]
      expect(Permit.involving_related(project(:involves_none))).to eq [none_permit]
      expect(Permit.involving_related(project(:involves_threatened_endangered_species))).to eq [endangered_permit]
    end
  end
end
