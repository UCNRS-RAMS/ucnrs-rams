require "rails_helper"

RSpec.describe ProjectsNewPresenter do
  describe "delegations" do
    subject { ProjectsNewPresenter.new(user: :dummy, current_step: 1) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
  end

  describe "#partial_name" do
    it "generates the name of the partial to render from project_type" do
      presenter = ProjectsNewPresenter.new(
        user: :dummy,
        current_step: 1,
        project_type: :meeting_or_conference
      )

      expect(presenter.partial_name).to eq "projects/meeting_or_conference_form"
    end
  end

  describe "#project_type_options" do
    it "lists the types of projects" do
      presenter = ProjectsNewPresenter.new(user: :dummy, current_step: 1)

      expect(presenter.project_type_options).to eq [
        :research,
        :university_class,
        :meeting_or_conference,
      ]
    end
  end

  describe "#disciplines" do
    it "lists all of the project disciplines" do
      presenter =  ProjectsNewPresenter.new(user: :dummy, current_step: 1)

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
      presenter =  ProjectsNewPresenter.new(user: :dummy, current_step: 1)
      
      expect(presenter.other_discipline?("Other")).to eq true
    end

    it "is false if the supplied discipline is not 'Other'" do
      presenter =  ProjectsNewPresenter.new(user: :dummy, current_step: 1)
      
      expect(presenter.other_discipline?("Arts/Humanities")).to eq false
    end
  end

  describe "#involvement_flags" do
    it "is an array containing the involvement-related attributes" do
      presenter = ProjectsNewPresenter.new(user: :dummy, current_step: 1)

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
      presenter = ProjectsNewPresenter.new(user: :dummy, current_step: 1)

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
      presenter =  ProjectsNewPresenter.new(user: :dummy, current_step: 1)

      expect(presenter.chemical_question?(planning_question)).to eq true
    end

    it "is false if the supplied planning_question is not method_chemicals" do
      planning_question = :method_remove_organisms
      presenter =  ProjectsNewPresenter.new(user: :dummy, current_step: 1)

      expect(presenter.chemical_question?(planning_question)).to eq false
    end
  end
end
