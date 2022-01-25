class EditProjectFlow
  def initialize(page)
    @page = ScopablePage.new(page)
  end

  def visit_project_edit_page(project)
    page.visit("/projects/#{project.id}/edit")
    page.find("body.projects-edit")
  end

  def has_form_already_filled_out?(
    title:,
    thesis_title:,
    abstract:,
    project_type:,
    start_date:,
    end_date:,
    discipline:,
    discipline_other:,
    involves_mammals:,
    involves_reptiles:,
    involves_amphibians:,
    involves_fish:,
    involves_birds:,
    involves_plants_fungi_soil:,
    involves_threatened_endangered_species:,
    involves_none:,
    method_description:,
    method_study_area:,
    method_remove_organisms:,
    method_transfer_organisms:,
    method_study_non_native_species:,
    method_chemicals:,
    method_chemicals_list:,
    method_soil_disturbance:,
    method_long_term_structures:,
    keywords:,
    taxonomic_keywords:,
    recent_publications:
  )
    Assertions.all(page) do |assert|
      assert.has_field?("Project or Event Title", with: title)
      assert.has_field?("Thesis Title", with: thesis_title)
      assert.has_field?("Project Abstract", with: abstract)
      assert.has_field?("discipline-#{discipline}", checked: true)
      if discipline == "other"
        assert.has_field?("project_discipline_other", with: discipline_other)
      end
      assert.has_field?("Mammals", checked: involves_mammals)
      assert.has_field?("Reptiles", checked: involves_reptiles)
      assert.has_field?("Amphibians", checked: involves_amphibians)
      assert.has_field?("Fish", checked: involves_fish)
      assert.has_field?("Birds", checked: involves_birds)
      assert.has_field?("Plants, Fungi, or Soils", checked: involves_plants_fungi_soil)
      assert.has_field?("Threatened, Endangered, or Species of Special Concern", checked: involves_threatened_endangered_species)
      assert.has_field?("None of the Above", checked: involves_none)
      assert.has_field?("Start Date", with: start_date)
      assert.has_field?("End Date", with: end_date)
      assert.has_field?("Project Keywords (Optional)", with: keywords)
      assert.has_field?("Taxonomic Keywords (Optional)", with: taxonomic_keywords)
      assert.has_field?("Recent Publications (Optional)", with: recent_publications)
      assert.has_field?("Environmental Manipulations Needed", with: method_description)
      assert.has_field?("Describe where you will be working on the reserve.", with: method_study_area)
      assert.has_field?("project_method_remove_organisms_#{method_remove_organisms ? "yes" : "no"}", checked: true)
      assert.has_field?("project_method_transfer_organisms_#{method_transfer_organisms ? "yes" : "no"}", checked: true)
      assert.has_field?("project_method_study_non_native_species_#{method_study_non_native_species ? "yes" : "no"}", checked: true)
      assert.has_field?("project_method_chemicals_#{method_chemicals ? "yes" : "no"}", checked: true)
      if method_chemicals == "yes"
        assert.has_field?("project_method_chemicals_list", with: method_chemicals_list)
      end
      assert.has_field?("project_method_soil_disturbance_#{method_soil_disturbance ? "yes" : "no"}", checked: true)
      assert.has_field?("project_method_long_term_structures_#{method_long_term_structures ? "yes" : "no"}", checked: true)
    end
  end

  def fill_out_new_project_form(
    title:,
    thesis_title:,
    abstract:,
    project_type:,
    start_date:,
    end_date:,
    discipline:,
    discipline_other:,
    involves_mammals:,
    involves_reptiles:,
    involves_amphibians:,
    involves_fish:,
    involves_birds:,
    involves_plants_fungi_soil:,
    involves_threatened_endangered_species:,
    involves_none:,
    method_description:,
    method_study_area:,
    method_remove_organisms:,
    method_transfer_organisms:,
    method_study_non_native_species:,
    method_chemicals:,
    method_chemicals_list:,
    method_soil_disturbance:,
    method_long_term_structures:,
    keywords:,
    taxonomic_keywords:,
    recent_publications:
  )
    page.fill_in("Project or Event Title", with: title)
    page.fill_in("Thesis Title", with: thesis_title)
    page.fill_in("Project Abstract", with: abstract)
    page.choose(discipline)
    if discipline == "Other"
      page.fill_in("project_discipline_other", with: discipline_other)
    end
    page.check("Mammals") if involves_mammals
    page.check("Reptiles") if involves_reptiles
    page.check("Amphibians") if involves_amphibians
    page.check("Fish") if involves_fish
    page.check("Birds") if involves_birds
    page.check("Plants, Fungi, or Soils") if involves_plants_fungi_soil
    page.check("Threatened, Endangered, or Species of Special Concern") if involves_threatened_endangered_species
    page.check("None of the Above") if involves_none
    page.fill_in("Start Date", with: start_date)
    page.fill_in("End Date", with: end_date)
    page.fill_in("Project Keywords (Optional)", with: keywords)
    page.fill_in("Taxonomic Keywords (Optional)", with: taxonomic_keywords)
    page.fill_in("Recent Publications (Optional)", with: recent_publications)
    page.fill_in("Environmental Manipulations Needed", with: method_description)
    page.fill_in("Describe where you will be working on the reserve.", with: method_study_area)
    page.choose("project_method_remove_organisms_#{method_remove_organisms.downcase}")
    page.choose("project_method_transfer_organisms_#{method_transfer_organisms.downcase}")
    page.choose("project_method_study_non_native_species_#{method_study_non_native_species.downcase}")
    page.choose("project_method_chemicals_#{method_chemicals.downcase}")
    if method_chemicals == "yes"
      page.fill_in("project_method_chemicals_list", with: method_chemicals_list)
    end
    page.choose("project_method_soil_disturbance_#{method_soil_disturbance.downcase}")
    page.choose("project_method_long_term_structures_#{method_long_term_structures.downcase}")
  end

  def submit_project_form
    page.find("button[form='projects-edit']").click
  end

  def on_project_teams_page?
    page.has_css?("body.team_memberships-index")
  end

  def visit_project_fundings_page(project)
    page.visit("/projects/#{project.id}/fundings")
  end

  def allowed_to_view_project_fundings_page?
    page.has_css?("body.fundings-index")
  end

  private

  attr_reader :page
end
