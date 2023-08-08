require "rails_helper"

RSpec.describe "app/views/projects/_class_form.html.erb", type: :view do
  it "has the required fields in the 'Details' section" do
    presenter = ProjectFormPresenter.new(
      user: :fake_user,
      current_step: 1,
    )

    FakeForm.fields_for(ProjectForm.new) do |form|
      render partial: "shared/projects/class_form",
        locals: { presenter: presenter, form: form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_field("Project or Event Title", type: "text")
    expect(doc).to have_field("Course Name", type: "text")
    expect(doc).to have_field("Course Number", type: "text")
  end

  it "has the required fields in the 'Disciplines' section" do
    presenter = ProjectFormPresenter.new(
      user: :fake_user,
      current_step: 1,
    )

    FakeForm.fields_for(ProjectForm.new) do |form|
      render partial: "shared/projects/class_form",
        locals: { presenter: presenter, form: form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_field("Agriculture", type: "radio")
    expect(doc).to have_field("Arts/Humanities", type: "radio")
    expect(doc).to have_field("Medical, Health & Safety", type: "radio")
    expect(doc).to have_field("Biology", type: "radio")
    expect(doc).to have_field("Earth Sciences", type: "radio")
    expect(doc).to have_field("Education", type: "radio")
    expect(doc).to have_field("Engineering/Computer Science", type: "radio")
    expect(doc).to have_field("Environmental Science/Natural Resources", type: "radio")
    expect(doc).to have_field("Physical Sciences", type: "radio")
    expect(doc).to have_field("Social Sciences", type: "radio")
    expect(doc).to have_field("Veterinary Medicine", type: "radio")
    expect(doc).to have_field("Other", type: "radio")
    expect(doc).to have_field("project_discipline_other", type: "text")
  end

  it "has the required fields in the 'Involvements' section" do
    presenter = ProjectFormPresenter.new(
      user: :fake_user,
      current_step: 1,
    )

    FakeForm.fields_for(ProjectForm.new) do |form|
      render partial: "shared/projects/class_form",
        locals: { presenter: presenter, form: form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_field("Mammals", type: "checkbox")
    expect(doc).to have_field("Reptiles", type: "checkbox")
    expect(doc).to have_field("Amphibians", type: "checkbox")
    expect(doc).to have_field("Fish", type: "checkbox")
    expect(doc).to have_field("Birds", type: "checkbox")
    expect(doc).to have_field("Plants, Fungi, or Soils", type: "checkbox")
    expect(doc).to have_field("Threatened, Endangered, or Species of Special Concern", type: "checkbox")
    expect(doc).to have_field("None of the Above", type: "checkbox")
  end

  it "has start and end date fields" do
    presenter = ProjectFormPresenter.new(
      user: :fake_user,
      current_step: 1,
    )

    FakeForm.fields_for(ProjectForm.new) do |form|
      render partial: "shared/projects/class_form",
        locals: { presenter: presenter, form: form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_field("Start Date", type: "date")
    expect(doc).to have_field("End Date", type: "date")
  end

  it "has the required fields in the 'Keywords' section" do
    presenter = ProjectFormPresenter.new(
      user: :fake_user,
      current_step: 1,
    )

    FakeForm.fields_for(ProjectForm.new) do |form|
      render partial: "shared/projects/class_form",
        locals: { presenter: presenter, form: form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_field("Project Keywords (Optional)", type: "textarea")
    expect(doc).to have_field("Taxonomic Keywords (Optional)", type: "textarea")
    expect(doc).to have_field("Recent Publications (Optional)", type: "textarea")
  end

  it "has the required fields in the 'Class Activities' section" do
    presenter = ProjectFormPresenter.new(
      user: :fake_user,
      current_step: 1,
    )

    FakeForm.fields_for(ProjectForm.new) do |form|
      render partial: "shared/projects/class_form",
        locals: { presenter: presenter, form: form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_field("Please provide a detailed description of environmental manipulations needed for your research.", type: "textarea")
  end

  it "has the required fields in the 'Planning Questions' section" do
    presenter = ProjectFormPresenter.new(
      user: :fake_user,
      current_step: 1,
    )

    FakeForm.fields_for(ProjectForm.new) do |form|
      render partial: "shared/projects/class_form",
        locals: { presenter: presenter, form: form }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_content("Remove organisms or materials from the reserve?")
    expect(doc).to have_field("project_method_remove_organisms_yes", type: "radio")
    expect(doc).to have_field("project_method_remove_organisms_no", type: "radio")
    expect(doc).to have_content("Transfer animals and plants from outside the reserve to within the reserve, or between different parts of the reserve?")
    expect(doc).to have_field("project_method_transfer_organisms_yes", type: "radio")
    expect(doc).to have_field("project_method_transfer_organisms_no", type: "radio")
    expect(doc).to have_content("Study or manipulate non-native species?")
    expect(doc).to have_field("project_method_study_non_native_species_yes", type: "radio")
    expect(doc).to have_field("project_method_study_non_native_species_no", type: "radio")
    expect(doc).to have_content("Use radioactive isotopes or other chemicals? (e.g., pesticides, herbicides, fertilizers, tracers)")
    expect(doc).to have_field("project_method_chemicals_yes", type: "radio")
    expect(doc).to have_field("project_method_chemicals_no", type: "radio")
    expect(doc).to have_field("project_method_chemicals_list", type: "text")
    expect(doc).to have_content("Disturb the soil?")
    expect(doc).to have_field("project_method_soil_disturbance_yes", type: "radio")
    expect(doc).to have_field("project_method_soil_disturbance_no", type: "radio")
    expect(doc).to have_content("Erect structures or deploy long term equipment, such as markers, fences, enclosures, cages, data-loggers, antennas, or buoys?")
    expect(doc).to have_field("project_method_long_term_structures_yes", type: "radio")
    expect(doc).to have_field("project_method_long_term_structures_no", type: "radio")
  end

  context "when displaying errors" do
    it "displays errors on all validated fields" do
      user = User.new
      project_form = ProjectForm.new(params: { project_type: :class }, user: user)
      project_form.validate
      presenter = ProjectFormPresenter.new(
        user: user,
        current_step: 1,
        project_type: :class,
        form: project_form,
      )

      FakeForm.fields_for(project_form) do |form|
        render partial: "shared/projects/class_form",
          locals: { presenter: presenter, form: form }
      end

      doc = Capybara.string(rendered)
      expect(doc).to display_error(I18n.t("activerecord.errors.messages.blank"))
        .for_field("Project or Event Title")
      expect(doc).to display_error(I18n.t("activerecord.errors.messages.blank"))
        .for_field("Course Name")
      expect(doc).to display_error(I18n.t("activerecord.errors.messages.blank"))
        .for_field("Course Number")
      expect(doc).to display_error("must select at least one")
        .for_field("Will your project involve any of the following?")
      expect(doc).to display_error(I18n.t("activerecord.errors.messages.blank"))
        .for_field("Start Date")
      expect(doc).to display_error(I18n.t("activerecord.errors.messages.blank"))
        .for_field("End Date")
      expect(doc).to display_error(
          I18n.t("activerecord.errors.models.project.attributes.method_remove_organisms.inclusion")
        )
        .for_field("Remove organisms or materials from the reserve?")
      expect(doc).to display_error(
          I18n.t("activerecord.errors.models.project.attributes.method_transfer_organisms.inclusion")
        )
        .for_field("Transfer animals and plants from outside the reserve to within the reserve, or between different parts of the reserve?")
      expect(doc).to display_error(
          I18n.t("activerecord.errors.models.project.attributes.method_study_non_native_species.inclusion")
        )
        .for_field("Study or manipulate non-native species?")
      expect(doc).to display_error(
          I18n.t("activerecord.errors.models.project.attributes.method_chemicals.inclusion")
        )
        .for_field("Use radioactive isotopes or other chemicals? (e.g., pesticides, herbicides, fertilizers, tracers")
      expect(doc).to display_error(
          I18n.t("activerecord.errors.models.project.attributes.method_soil_disturbance.inclusion")
        )
        .for_field("Disturb the soil?")
      expect(doc).to display_error(
          I18n.t("activerecord.errors.models.project.attributes.method_long_term_structures.inclusion")
        )
        .for_field("Erect structures or deploy long term equipment, such as markers, fences, enclosures, cages, data-loggers, antennas, or buoys?")
    end
  end
end
