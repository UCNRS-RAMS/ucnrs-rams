require "rails_helper"

RSpec.describe UserFilter do
  describe "#user_search_filter" do
    context "when :user_search is present" do
      it "returns a strip :user_search" do
        filter = { user_search: "  keyword  " }
        user_filter = UserFilter.new(filter)

        result = user_filter.user_search_filter
    
        expect(result).to eq "keyword"
      end
    end

    context "when :user_search is not present" do
      it "returns empty string" do
        filter = { user_search: "" }
        user_filter = UserFilter.new(filter)

        result = user_filter.user_search_filter
    
        expect(result).to eq ""
      end
    end
  end

  describe "#sort_by_filter" do
    context "when :sort_by is present" do
      it "returns :sort_by" do
        filter = { sort_by: "keyword" }
        user_filter = UserFilter.new(filter)

        result = user_filter.sort_by_filter
    
        expect(result).to eq "keyword"
      end
    end

    context "when :sort_by is not present" do
      it "returns DEFAULT_SORT_BY_FILTER" do
        filter = { sort_by: "" }
        user_filter = UserFilter.new(filter)

        result = user_filter.sort_by_filter
    
        expect(result).to eq UserFilter::DEFAULT_SORT_BY_FILTER
      end
    end
  end

  describe "#user_role_filter" do
    context "when :user_role is present" do
      it "returns given :user_role" do
        filter = { user_role: "docent" }
        user_filter = UserFilter.new(filter)

        result = user_filter.user_role_filter
    
        expect(result).to eq "docent"
      end
    end

    context "when :user_role is not present" do
      it "returns DEFAULT_USER_ROLE_FILTER" do
        filter = { user_role: "" }
        user_filter = UserFilter.new(filter)

        result = user_filter.user_role_filter
    
        expect(result).to eq UserFilter::DEFAULT_USER_ROLE_FILTER
      end
    end
  end

  describe "#user_institution_type_filter" do
    context "when :user_institution_type is present" do
      it "returns given :user_institution_type" do
        filter = { user_institution_type: "individual_or_other_entity" }
        user_filter = UserFilter.new(filter)

        result = user_filter.user_institution_type_filter
    
        expect(result).to eq "individual_or_other_entity"
      end
    end

    context "when :user_institution_type is not present" do
      it "returns DEFAULT_USER_INSTITUTION_TYPE_FILTER" do
        filter = { user_institution_type: "" }
        user_filter = UserFilter.new(filter)

        result = user_filter.user_institution_type_filter
    
        expect(result).to eq UserFilter::DEFAULT_USER_INSTITUTION_TYPE_FILTER
      end
    end
  end

  describe "#present?" do
    context "when given filter is .present?" do
      it "returns true" do
        filter = { anything: "anything" }
        user_filter = UserFilter.new(filter)

        result = user_filter.present?
    
        expect(result).to eq true
      end
    end

    context "when given filter is not .present?" do
      it "returns false" do
        filter = { }
        user_filter = UserFilter.new(filter)

        result = user_filter.present?
    
        expect(result).to eq false
      end
    end
  end
end
