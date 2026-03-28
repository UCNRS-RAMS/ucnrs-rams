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
    it { is_expected.to have_many(:project_permit_answers) }
    it { is_expected.to have_many(:projects).through(:project_permit_answers) }
    it { is_expected.to have_many(:reserve_permits) }
    it { is_expected.to have_many(:reserves).through(:reserve_permits) }
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

  describe ".for_visits" do
    it "only selects permits with a location of visit" do
      visit_permit = create(:permit, location: :visit)
      project_permit = create(:permit, location: :project)

      expect(Permit.for_visits).to eq [visit_permit]
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
      class_permit = create(:permit, research: false, university_class: true)
      conference_permit = create(:permit, research: false, conference: true)
      public_permit = create(:permit, research: false, public: true)
      housing_permit = create(:permit, research: false, housing: true)

      expect(Permit.matching_project_type("rEsearch")).to eq [research_permit]
      expect(Permit.matching_project_type("CLASS")).to eq [class_permit]
      expect(Permit.matching_project_type("meeting")).to eq [conference_permit]
      expect(Permit.matching_project_type("PuBlIc_UsE")).to eq [public_permit]
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

    def project(boolean_key, value: true)
      build(:project, involves_none: false, boolean_key => value)
    end

    it "returns the permit if the involvements match the project's involvements" do
      mammals_permit = create(:permit, involves_mammals: true)
      reptiles_permit = create(:permit, involves_reptiles: true)
      amphibians_permit = create(:permit, involves_amphibians: true)
      fish_permit = create(:permit, involves_fish: true)
      birds_permit = create(:permit, involves_birds: true)
      plants_fungi_soil_permit = create(:permit, involves_plants_fungi_soil: true)
      endangered_permit = create(:permit, threatened_endangered_flag: true)

      expect(Permit.involving_related(project(:involves_mammals))).to eq [mammals_permit]
      expect(Permit.involving_related(project(:involves_reptiles))).to eq [reptiles_permit]
      expect(Permit.involving_related(project(:involves_amphibians))).to eq [amphibians_permit]
      expect(Permit.involving_related(project(:involves_fish))).to eq [fish_permit]
      expect(Permit.involving_related(project(:involves_birds))).to eq [birds_permit]
      expect(Permit.involving_related(project(:involves_plants_fungi_soil))).to eq [plants_fungi_soil_permit]
      expect(Permit.involving_related(project(:involves_threatened_endangered_species))).to eq [endangered_permit]
    end
  end

  describe ".include_answers_for" do
    it "adds #answer and #answer_id in the query representing a ProjectPermitAnswer" do
      project = create(:project, project_type: :research)
      permit1 = create(:permit, visible: true, involves_all: true)
      answer1 = create(:project_permit_answer, project: project, permit: permit1, answer: true)
      permit2 = create(:permit, visible: true, involves_all: true)
      permit3 = create(:permit, visible: true, involves_all: true)
      answer3 = create(:project_permit_answer, project: project, permit: permit3, answer: false)

      permits = Permit.include_answers_for(project).order(:id)

      expect(permits[0]).to eq permit1
      expect(permits[0].answer).to eq 1
      expect(permits[0].answer_id).to eq answer1.id
      expect(permits[1]).to eq permit2
      expect(permits[1].answer).to be_nil
      expect(permits[1].answer_id).to be_nil
      expect(permits[2]).to eq permit3
      expect(permits[2].answer).to eq 0
      expect(permits[2].answer_id).to eq answer3.id
    end

    it "only shows answers for the given permit-project pair" do
      project1 = create(:project, project_type: :research)
      project2 = create(:project, project_type: :research)
      question = create(:permit, involves_all: true)
      answer1 = create(:project_permit_answer, project: project1, permit: question)
      answer2 = create(:project_permit_answer, project: project2, permit: question)

      permits = Permit.include_answers_for(project2)

      expect(permits.length).to eq 1
      expect(permits[0].answer_id).to eq answer2.id
    end

    it "returns permits even if there is no answer for that project yet" do
      project1 = create(:project, project_type: :research)
      project2 = create(:project, project_type: :research)
      question = create(:permit, involves_all: true)
      answer = create(:project_permit_answer, project: project1, permit: question)

      permits = Permit.include_answers_for(project2)

      expect(permits.length).to eq 1
      expect(permits[0].answer_id).to be_nil
    end
  end

  describe ".of_iacuc_type" do
    it "only selects permits where iacuc is true" do
      iacuc_permit = create(:permit, iacuc: true)
      non_iacuc_permit = create(:permit, iacuc: false)

      expect(Permit.of_iacuc_type).to eq [iacuc_permit]
    end
  end

  describe ".with_flag_type" do
    it "filters permits by the given flag type" do
      iacuc_permit = create(:permit, iacuc: true)
      drone_permit = create(:permit, drone_flag: true)
      scuba_permit = create(:permit, scuba_flag: true)
      unflagged_permit = create(:permit, iacuc: false, drone_flag: false, scuba_flag: false)

      expect(Permit.with_flag_type("iacuc_flag")).to eq [iacuc_permit]
      expect(Permit.with_flag_type("drone_flag")).to eq [drone_permit]
      expect(Permit.with_flag_type("scuba_flag")).to eq [scuba_permit]
    end

    it "is case-insensitive" do
      iacuc_permit = create(:permit, iacuc: true)

      expect(Permit.with_flag_type("IACUC_FLAG")).to eq [iacuc_permit]
    end

    it "returns no results for an unknown flag type" do
      create(:permit, iacuc: true)

      expect(Permit.with_flag_type("unknown_flag")).to be_empty
    end
  end
end
