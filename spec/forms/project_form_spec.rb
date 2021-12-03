require "rails_helper"

RSpec.describe ProjectForm, type: :model do
  describe "delegations" do
    it { is_expected.to delegate_method(:valid?).to(:project) }
    it { is_expected.to delegate_method(:validate).to(:project) }
    it { is_expected.to delegate_method(:errors).to(:project) }
  end

  describe "#save" do
    it "saves the project if there are no errors" do
      user = create(:user)
      form = ProjectForm.new(user: user, params: {
        title: "Project Title",
        abstract: "A summary of the project",
        project_type: :research,
        start_date: Date.new(2021, 12, 1),
        end_date: Date.new(2022, 12, 1),
        discipline: "Other",
        discipline_other: "Another Discipline",
        involves_mammals: true,
        involves_reptiles: nil,
        involves_amphibians: nil,
        involves_fish: nil,
        involves_birds: nil,
        involves_plants_fungi_soil: nil,
        involves_threatened_endangered_species: nil,
        involves_none: nil,
        method_description: "How the project will be conducted",
        method_study_area: "Where the project will be conducted",
        method_remove_organisms: "Yes",
        method_transfer_organisms: "No",
        method_study_non_native_species: "No",
        method_chemicals: "Yes",
        method_chemicals_list: "A list of chemicals",
        method_soil_disturbance: "No",
        method_long_term_structures: "No",
      })

      result = form.save

      expect(result).to be_truthy
      expect(form.project).to be_persisted
      expect(form.project).to have_attributes(
        title: "Project Title",
        abstract: "A summary of the project",
        project_type: "research",
        start_date: Date.new(2021, 12, 1),
        end_date: Date.new(2022, 12, 1),
        discipline: "Other",
        discipline_other: "Another Discipline",
        involves_mammals: true,
        involves_reptiles: nil,
        involves_amphibians: nil,
        involves_fish: nil,
        involves_birds: nil,
        involves_plants_fungi_soil: nil,
        involves_threatened_endangered_species: nil,
        involves_none: nil,
        method_description: "How the project will be conducted",
        method_study_area: "Where the project will be conducted",
        method_remove_organisms: true,
        method_transfer_organisms: false,
        method_study_non_native_species: false,
        method_chemicals: true,
        method_chemicals_list: "A list of chemicals",
        method_soil_disturbance: false,
        method_long_term_structures: false,
      )
    end

    it "makes sure errors are visible when save fails" do
      user = create(:user)
      form = ProjectForm.new(user: user, params: {
        title: "",
        abstract: "A summary of the project",
        project_type: :research,
        start_date: "",
        end_date: "",
        discipline: "Agriculture",
        discipline_other: nil,
        involves_mammals: nil,
        involves_reptiles: nil,
        involves_amphibians: nil,
        involves_fish: nil,
        involves_birds: nil,
        involves_plants_fungi_soil: nil,
        involves_threatened_endangered_species: nil,
        involves_none: nil,
        method_description: "How the project will be conducted",
        method_study_area: "Where the project will be conducted",
        method_remove_organisms: "Yes",
        method_transfer_organisms: "No",
        method_study_non_native_species: "No",
        method_chemicals: nil,
        method_chemicals_list: nil,
        method_soil_disturbance: "No",
        method_long_term_structures: "No",
      })

      result = form.save

      expect(result).to be_falsy
      expect(form.project).to_not be_persisted
      expect(form.errors).to be_present
    end

    it "creates a project_team_membership between the user and the project" do
      user = create(:user)
      form = ProjectForm.new(user: user, params: {
        title: "Project Title",
        abstract: "A summary of the project",
        project_type: :research,
        start_date: Date.new(2021, 12, 1),
        end_date: Date.new(2022, 12, 1),
        discipline: "Other",
        discipline_other: "Another Discipline",
        involves_mammals: true,
        involves_reptiles: nil,
        involves_amphibians: nil,
        involves_fish: nil,
        involves_birds: nil,
        involves_plants_fungi_soil: nil,
        involves_threatened_endangered_species: nil,
        involves_none: nil,
        method_description: "How the project will be conducted",
        method_study_area: "Where the project will be conducted",
        method_remove_organisms: "Yes",
        method_transfer_organisms: "No",
        method_study_non_native_species: "No",
        method_chemicals: "Yes",
        method_chemicals_list: "A list of chemicals",
        method_soil_disturbance: "No",
        method_long_term_structures: "No",
      })

      form.save

      project_team_memberships = form.project.team_memberships
      expect(project_team_memberships.length).to eq 1
      expect(project_team_memberships[0]).to have_attributes(
        project_id: form.project.id,
        user_id: user.id,
        institution_id: user.institution.id,
        user_role: user.role,
        is_principal_investigator: true,
        can_edit_project: true,
        can_add_project_user: true,
        can_add_visit: true,
        can_receive_invoice: true,
      )
    end
  end

  describe "initializing" do
    it "makes an empty ProjectForm from empty params" do
      form = ProjectForm.new

      expect(form).to have_attributes(
        title: nil,
        thesis_title: nil,
        abstract: nil,
        project_type: "research",
        start_date: "",
        end_date: "",
        discipline: nil,
        discipline_other: nil,
        involves_mammals: nil,
        involves_reptiles: nil,
        involves_amphibians: nil,
        involves_fish: nil,
        involves_birds: nil,
        involves_plants_fungi_soil: nil,
        involves_threatened_endangered_species: nil,
        involves_none: nil,
        method_description: nil,
        method_study_area: nil,
        method_remove_organisms: nil,
        method_transfer_organisms: nil,
        method_study_non_native_species: nil,
        method_chemicals: nil,
        method_chemicals_list: nil,
        method_soil_disturbance: nil,
        method_long_term_structures: nil,
        course_title: nil,
        course_number: nil,
        keywords: nil,
        taxonomic_keywords: nil,
        recent_publications: nil,
      )
    end

    it "makes a new ProjectForm from params" do
      params = {
        title: "Project Title",
        abstract: "A summary of the project",
        project_type: :research,
        start_date: Date.new(2021, 12, 1),
        end_date: Date.new(2022, 12, 1),
        discipline: "Agriculture",
        involves_mammals: true,
        involves_reptiles: nil,
        involves_amphibians: nil,
        involves_fish: nil,
        involves_birds: nil,
        involves_plants_fungi_soil: nil,
        involves_threatened_endangered_species: nil,
        involves_none: nil,
        method_description: "How the project will be conducted",
        method_study_area: "Where the project will be conducted",
        method_remove_organisms: "Yes",
        method_transfer_organisms: "No",
        method_study_non_native_species: "No",
        method_chemicals: "Yes",
        method_chemicals_list: "A list of chemicals",
        method_soil_disturbance: "No",
        method_long_term_structures: "No",
      }
      form = ProjectForm.new(user: build(:user), params: params)

      expect(form).to have_attributes(
        title: "Project Title",
        abstract: "A summary of the project",
        project_type: "research",
        start_date: "2021-12-01",
        end_date: "2022-12-01",
        discipline: "Agriculture",
        involves_mammals: true,
        involves_reptiles: nil,
        involves_amphibians: nil,
        involves_fish: nil,
        involves_birds: nil,
        involves_plants_fungi_soil: nil,
        involves_threatened_endangered_species: nil,
        involves_none: nil,
        method_description: "How the project will be conducted",
        method_study_area: "Where the project will be conducted",
        method_remove_organisms: "Yes",
        method_transfer_organisms: "No",
        method_study_non_native_species: "No",
        method_chemicals: "Yes",
        method_chemicals_list: "A list of chemicals",
        method_soil_disturbance: "No",
        method_long_term_structures: "No",
      )
    end
  end

  describe "#radio_value_for" do
    it "is 'Yes' if the value of the supplied attribute is 'Yes'" do
      form = ProjectForm.new(params: { method_transfer_organisms: "Yes" })

      expect(form.method_transfer_organisms).to eq "Yes"
    end

    it "is 'No' if the value of the supplied attribute is 'No'" do
      form = ProjectForm.new(params: { method_transfer_organisms: "No" })

      expect(form.method_transfer_organisms).to eq "No"
    end

    it "is nil if the value of the supplied attribute is anything else" do
      form = ProjectForm.new(params: { method_transfer_organisms: "Anything else" })

      expect(form.method_transfer_organisms).to be_nil
    end
  end

  describe "#boolean_value_from" do
    it "is true if the supplied value is 'Yes'" do
      form = ProjectForm.new(params: { method_transfer_organisms: "Yes" })

      expect(form.project.method_transfer_organisms).to eq true
    end

    it "is false if the suppled value is 'No'" do
      form = ProjectForm.new(params: { method_transfer_organisms: "No" })

      expect(form.project.method_transfer_organisms).to eq false
    end

    it "is nil if the suppled value is anything else" do
      form = ProjectForm.new(params: { method_transfer_organisms: nil })

      expect(form.project.method_transfer_organisms).to be_nil
    end
  end

  describe "#parse_date" do
    it "parses a date in %Y-%m-%d format" do
      form = ProjectForm.new

      form.start_date = "1999-2-1"

      start_date = form.project.start_date
      expect(start_date.year).to eq 1999
      expect(start_date.month).to eq 2
      expect(start_date.day).to eq 1
    end

    it "returns nil if there is an error in parsing the date" do
      form = ProjectForm.new

      form.start_date = "CHRISTMAS!"

      start_date = form.project.start_date
      expect(start_date).to be_nil
    end
  end
end
