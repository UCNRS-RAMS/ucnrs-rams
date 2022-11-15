require "rails_helper"

RSpec.describe Manager::InstitutionsIndexPresenter do
  describe "delegations" do
    subject { Manager::InstitutionsIndexPresenter.new() }
    it { is_expected.to delegate_method(:institution_search_filter).to(:filter) }
    it { is_expected.to delegate_method(:institution_sort_by_filter).to(:filter) }
    it { is_expected.to delegate_method(:institution_country_filter).to(:filter) }
    it { is_expected.to delegate_method(:institution_type_filter).to(:filter) }
    it { is_expected.to delegate_method(:present?).to(:filter).with_prefix(true) }
  end

  describe "#institutions" do
    it "presents the institution records wrapped in InstitutionPresenter" do
      institution1 = create(:institution)
      institution2 = create(:institution)
      presenter = Manager::InstitutionsIndexPresenter.new()

      institutions = presenter.institutions

      expect(institutions.map(&:id)).to match_array [institution1.id, institution2.id]
      expect(institutions).to all(be_a(InstitutionPresenter))
    end
  end

  describe "#institution_scope" do
    it "returns only institutions with name, city, acronym or country containing the given search term" do
      institution1 = create(:institution, name: "institution name")
      create(:institution, name: "name 1")
      create(:institution, name: "name 2")
      institution2 = create(:institution, city: "institution city")
      institution3 = create(:institution, acronym: "inst")
      institution4 = create(:institution, country: create(:country, name: "institution country"))
      presenter = Manager::InstitutionsIndexPresenter.new(filter: { institution_search: "inst" })

      institution_scope = presenter.institution_scope

      expect(institution_scope).to match_array [institution1, institution2, institution3, institution4]
    end

    it "returns only institutions with given country id" do
      country1 = create(:country)
      country2 = create(:country)
      institution1 = create(:institution, country: country1)
      create(:institution, country: country2)
      presenter = Manager::InstitutionsIndexPresenter.new(filter: { institution_country: country1.id })

      institution_scope = presenter.institution_scope

      expect(institution_scope).to match_array [institution1]
    end

    it "returns only institutions with given with_institution_type" do
      uc_type_institution = create(:institution, institution_type: "university_of_california")
      k_12_type_institution = create(:institution, institution_type: "k_12_education")
      business_entity_type_institution = create(:institution, institution_type: "business_entity")
      presenter = Manager::InstitutionsIndexPresenter.new(
        filter: { institution_type: "university_of_california" }
      )

      institution_scope = presenter.institution_scope

      expect(institution_scope).to match_array [uc_type_institution]
    end


    context "when given sort_by 'created_at'" do
      it "returns institutions sorted by latest created_at first" do
        institution1 = create(:institution, created_at: 2.year.ago)
        institution2 = create(:institution, created_at: 3.year.ago)
        institution3 = create(:institution, created_at: 1.year.ago)
        institution4 = create(:institution, created_at: 4.year.ago)
        presenter = Manager::InstitutionsIndexPresenter.new(filter: { institution_sort_by: "created_at" })

        institution_scope = presenter.institution_scope

        expect(institution_scope).to eq [institution3, institution1, institution2, institution4]
      end
    end

    context "when given sort_by 'name'" do
      it "returns institutions sorted by name alphabetically" do
        institution1 = create(:institution, name: "d")
        institution2 = create(:institution, name: "a")
        institution3 = create(:institution, name: "z")
        institution4 = create(:institution, name: "y")
        presenter = Manager::InstitutionsIndexPresenter.new(filter: { institution_sort_by: "name" })

        institution_scope = presenter.institution_scope

        expect(institution_scope).to eq [institution2, institution1, institution4, institution3]
      end
    end


    it "returns a maximum of 10 institutions" do
      create_list(:institution, 11)
      presenter = Manager::InstitutionsIndexPresenter.new(page: 1)

      scope = presenter.institution_scope

      expect(scope.length).to eq 10
    end
  end

  describe "#institution_type_options" do
    it "is an array of institution type options translated" do
      allow(Institution).to receive(:institution_types).and_return(
        {
          "institution_type_1_key" => "institution_type_1",
          "institution_type_2_key" => "institution_type_2",
        }
      )
      allow(I18n).to receive(:t)
        .with("all")
        .and_return("all_translate")
      allow(I18n).to receive(:t)
        .with("universal.institution_types.institution_type_1_key")
        .and_return("institution_type_1_key_translate")
      allow(I18n).to receive(:t)
        .with("universal.institution_types.institution_type_2_key")
        .and_return("institution_type_2_key_translate")
      presenter = Manager::InstitutionsIndexPresenter.new()

      institution_type_options = presenter.institution_type_options

      expect(institution_type_options.to_a).to match_array [
        ["all_translate", nil],
        ["institution_type_1_key_translate", "institution_type_1_key"],
        ["institution_type_2_key_translate", "institution_type_2_key"],
      ]
    end
  end

  describe "#institution_country_options" do
    it "is an array of institution type options translated" do
      country1 = create(:country, name: "d")
      country2 = create(:country, name: "a")
      country3 = create(:country, name: "z")
      allow(I18n).to receive(:t)
        .with("all")
        .and_return("all_translate")
      presenter = Manager::InstitutionsIndexPresenter.new()

      institution_country_options = presenter.institution_country_options

      expect(institution_country_options).to eq [
        ["all_translate", nil],
        ["a", country2.id],
        ["d", country1.id],
        ["z", country3.id],
      ]
    end
  end

  describe "#institution_sort_by_options" do
    it "is an array of sort by options" do
      presenter = Manager::InstitutionsIndexPresenter.new()

      institution_sort_by_options = presenter.institution_sort_by_options

      expect(institution_sort_by_options.to_a).to match_array [
        [I18n.t("manager.institutions.search.name"), :name],
        [I18n.t("manager.institutions.search.date_created"), :created_at],
      ]
    end
  end
end
