require "rails_helper"

RSpec.describe ProjectFormPresenter do
  describe "delegations" do
    subject { ProjectFormPresenter.new(user: :dummy, current_step: 1) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
    it { is_expected.to delegate_method(:id).to(:form) }
  end

  describe "#partial_name" do
    it "generates the name of the partial to render from project_type" do
      presenter = ProjectFormPresenter.new(
        user: :dummy,
        current_step: 1,
        project_type: :meeting,
      )

      expect(presenter.partial_name).to eq "shared/projects/meeting_form"
    end
  end

  describe "#project_type_options" do
    it "lists the types of projects" do
      presenter = ProjectFormPresenter.new(user: :dummy, current_step: 1)

      expect(presenter.project_type_options).to eq [
        :research,
        :class,
        :meeting,
      ]
    end
  end

  describe "#disciplines" do
    it "lists all of the project disciplines" do
      presenter = ProjectFormPresenter.new(user: :dummy, current_step: 1)

      expect(presenter.disciplines).to eq [
        "Agriculture",
        "Arts/Humanities",
        "Astronomy",
        "Medical, Health & Safety",
        "Biology",
        "Earth Sciences",
        "Education",
        "Engineering/Computer Science",
        "Environmental Science/Natural Resources",
        "Physical Sciences",
        "Social Sciences",
        "Veterinary Medicine",
        "Other",
      ]
    end
  end

  describe "other_discipline?" do
    it "is true if the supplied discipline is 'Other'" do
      presenter =  ProjectFormPresenter.new(user: :dummy, current_step: 1)

      expect(presenter.other_discipline?("Other")).to eq true
    end

    it "is false if the supplied discipline is not 'Other'" do
      presenter = ProjectFormPresenter.new(user: :dummy, current_step: 1)

      expect(presenter.other_discipline?("Arts/Humanities")).to eq false
    end
  end

  describe "#involvement_flags" do
    it "is an array containing the involvement-related attributes" do
      presenter = ProjectFormPresenter.new(user: :dummy, current_step: 1)

      expect(presenter.involvement_flags).to eq [
        :involves_mammals,
        :involves_reptiles,
        :involves_amphibians,
        :involves_fish,
        :involves_birds,
        :involves_plants_fungi_soil,
        :involves_threatened_endangered_species,
        :involves_none,
      ]
    end
  end

  describe "#planning_questions" do
    it "is an array containing the planning question-related attributes" do
      presenter = ProjectFormPresenter.new(user: :dummy, current_step: 1)

      expect(presenter.planning_questions).to eq [
        :method_remove_organisms,
        :method_transfer_organisms,
        :method_study_non_native_species,
        :method_chemicals,
        :method_soil_disturbance,
        :method_long_term_structures,
      ]
    end
  end

  describe "chemical_question?" do
    it "is true if the supplied planning_question is :method_chemicals" do
      planning_question = :method_chemicals
      presenter = ProjectFormPresenter.new(user: :dummy, current_step: 1)

      expect(presenter.chemical_question?(planning_question)).to eq true
    end

    it "is false if the supplied planning_question is not method_chemicals" do
      planning_question = :method_remove_organisms
      presenter = ProjectFormPresenter.new(user: :dummy, current_step: 1)

      expect(presenter.chemical_question?(planning_question)).to eq false
    end
  end

  describe "#current_step_name" do
    it "returns a dynamic I18n key based on step name" do
      presenter = ProjectFormPresenter.new(user: :dummy, current_step: 1)

      expect(presenter.current_step_name).to eq ".submit.step_1"
    end
  end

  describe "#can_edit_project_type?" do
    it "is true if the project's status is 'incomplete'" do
      project = create(:project, status: "incomplete")
      form = ProjectForm.new(params: { id: project.id })
      presenter = ProjectFormPresenter.new(
        user: :dummy,
        current_step: 1,
        form: form,
      )

      expect(presenter).to be_able_to_edit_project_type
    end

    it "is false if the project's status is anything else" do
      project = create(:project, status: "open")
      form = ProjectForm.new(params: { id: project.id })
      presenter = ProjectFormPresenter.new(
        user: :dummy,
        current_step: 1,
        form: form,
      )

      expect(presenter).not_to be_able_to_edit_project_type
    end
  end
end
