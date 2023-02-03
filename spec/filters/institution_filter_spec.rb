require "rails_helper"

RSpec.describe InstitutionFilter do
  describe "delegations" do
    it { is_expected.to delegate_method(:present?).to(:filter) }
  end

  describe "#institution_search_filter" do
    context "when :institution_search is present" do
      it "returns a strip :institution_search" do
        filter = { institution_search: "  keyword  " }
        institution_filter = InstitutionFilter.new(filter)

        result = institution_filter.institution_search_filter

        expect(result).to eq "keyword"
      end
    end

    context "when :institution_search is not present" do
      it "returns empty string" do
        filter = { institution_search: "" }
        institution_filter = InstitutionFilter.new(filter)

        result = institution_filter.institution_search_filter

        expect(result).to eq ""
      end
    end
  end

  describe "#institution_sort_by_filter" do
    context "when :institution_sort_by is present" do
      it "returns :institution_sort_by" do
        filter = { institution_sort_by: "keyword" }
        institution_filter = InstitutionFilter.new(filter)

        result = institution_filter.institution_sort_by_filter

        expect(result).to eq "keyword"
      end
    end

    context "when :institution_sort_by is not present" do
      it "returns DEFAULT_INSTITUTION_SORT_BY_FILTER" do
        filter = { institution_sort_by: "" }
        institution_filter = InstitutionFilter.new(filter)

        result = institution_filter.institution_sort_by_filter

        expect(result).to eq InstitutionFilter::DEFAULT_INSTITUTION_SORT_BY_FILTER
      end
    end
  end

  describe "#institution_country_filter" do
    context "when :institution_country is present" do
      it "returns given :institution_country" do
        filter = { institution_country: "docent" }
        institution_filter = InstitutionFilter.new(filter)

        result = institution_filter.institution_country_filter

        expect(result).to eq "docent"
      end
    end

    context "when :institution_country is not present" do
      it "returns DEFAULT_INSTITUTION_COUNTRY_FILTER" do
        filter = { institution_country: "" }
        institution_filter = InstitutionFilter.new(filter)

        result = institution_filter.institution_country_filter

        expect(result).to eq InstitutionFilter::DEFAULT_INSTITUTION_COUNTRY_FILTER
      end
    end
  end

  describe "#institution_state_filter" do
    context "when :institution_state is present" do
      it "returns given :institution_state" do
        filter = { institution_state: "texas" }
        institution_filter = InstitutionFilter.new(filter)

        result = institution_filter.institution_state_filter

        expect(result).to eq "texas"
      end
    end

    context "when :institution_state is not present" do
      it "returns DEFAULT_INSTITUTION_STATE_FILTER" do
        filter = { institution_state: "" }
        institution_filter = InstitutionFilter.new(filter)

        result = institution_filter.institution_state_filter

        expect(result).to eq InstitutionFilter::DEFAULT_INSTITUTION_STATE_FILTER
      end
    end
  end

  describe "#institution_type_filter" do
    context "when :institution_type is present" do
      it "returns given :institution_type" do
        filter = { institution_type: "individual_or_other_entity" }
        institution_filter = InstitutionFilter.new(filter)

        result = institution_filter.institution_type_filter

        expect(result).to eq "individual_or_other_entity"
      end
    end

    context "when :institution_type is not present" do
      it "returns DEFAULT_INSTITUTION_TYPE_FILTER" do
        filter = { institution_type: "" }
        institution_filter = InstitutionFilter.new(filter)

        result = institution_filter.institution_type_filter

        expect(result).to eq InstitutionFilter::DEFAULT_INSTITUTION_TYPE_FILTER
      end
    end
  end
end
