require "rails_helper"

RSpec.describe VisitFilter do
  describe "#visit_search_filter" do
    context "if :sort_by is present" do
      it "returns a strip :visit_search" do
        filter = { visit_search: "  keyword  " }
        visit_filter = VisitFilter.new(filter)

        result = visit_filter.visit_search_filter

        expect(result).to eq "keyword"
      end
    end

    context "if :sort_by is not present" do
      it "returns a strip :visit_search" do
        filter = { visit_search: "" }
        visit_filter = VisitFilter.new(filter)

        result = visit_filter.visit_search_filter

        expect(result).to eq ""
      end
    end
  end

  describe "#sort_by_filter" do
    context "if :sort_by is present" do
      it "returns :sort_by" do
        filter = { sort_by: "keyword" }
        visit_filter = VisitFilter.new(filter)

        result = visit_filter.sort_by_filter

        expect(result).to eq "keyword"
      end
    end

    context "if :sort_by is not present" do
      it "returns DEFAULT_SORT_BY_FILTER" do
        filter = { sort_by: "" }
        visit_filter = VisitFilter.new(filter)

        result = visit_filter.sort_by_filter

        expect(result).to eq VisitFilter::DEFAULT_SORT_BY_FILTER
      end
    end
  end

  describe "#reserve_filter" do
    context "if :filter is nil" do
      it "returns given reserve.id" do
        filter = { reserve: nil }
        reserve = create(:reserve)
        visit_filter = VisitFilter.new(filter, reserve)

        result = visit_filter.reserve_filter

        expect(result).to eq reserve.id
      end
    end

    context "if :filter is not nil" do
      it "returns :filter" do
        filter = { reserve: "1" }
        visit_filter = VisitFilter.new(filter, nil)

        result = visit_filter.reserve_filter

        expect(result).to eq "1"
      end
    end
  end

  describe "#amenity_filter" do
    context "when :amenity is present and amenity with id = :amenity + reserve_id = reserve_filter then" do
      it "returns given :amenity" do
        reserve = create(:reserve)
        amenity = create(:amenity, reserve: reserve)
        filter = { amenity: amenity.id, reserve: reserve.id }
        visit_filter = VisitFilter.new(filter)

        result = visit_filter.amenity_filter

        expect(result).to eq amenity.id
      end
    end

    context "when :amenity is present and a reserve doesn't have amenity with id equal to :amenity then" do
      it "returns given DEFAULT_AMENITY_FILTER" do
        amenity = create(:amenity)
        filter = { amenity: amenity.id }
        visit_filter = VisitFilter.new(filter)

        result = visit_filter.amenity_filter

        expect(result).to eq VisitFilter::DEFAULT_AMENITY_FILTER
      end
    end

    context "if :amenity is not present" do
      it "returns DEFAULT_AMENITY_FILTER" do
        filter = { amenity: nil }
        visit_filter = VisitFilter.new(filter)

        result = visit_filter.amenity_filter

        expect(result).to eq VisitFilter::DEFAULT_AMENITY_FILTER
      end
    end
  end

  describe "#date_range_type_filter" do
    it "returns :date_range_type" do
      filter = { date_range_type: "range type" }
      visit_filter = VisitFilter.new(filter)

      result = visit_filter.date_range_type_filter

      expect(result).to eq "range type"
    end
  end

  describe "#visit_project_type_filter" do
    context "if :visit_project_type is present" do
      it "returns given :visit_project_type" do
        filter = { visit_project_type: "a project type" }
        visit_filter = VisitFilter.new(filter)

        result = visit_filter.visit_project_type_filter

        expect(result).to eq "a project type"
      end
    end

    context "if :visit_project_type is not present" do
      it "returns DEFAULT_VISIT_PROJECT_TYPE_FILTER" do
        filter = { visit_project_type: "" }
        visit_filter = VisitFilter.new(filter)

        result = visit_filter.visit_project_type_filter

        expect(result).to eq VisitFilter::DEFAULT_VISIT_PROJECT_TYPE_FILTER
      end
    end
  end

  describe "#date_begin_filter" do
    it "returns :date_begin" do
      date = Date.current
      filter = { date_begin: date }
      visit_filter = VisitFilter.new(filter)

      result = visit_filter.date_begin_filter

      expect(result).to eq date
    end
  end

  describe "#date_end_filter" do
    it "returns :date_end" do
      date = Date.current
      filter = { date_end: date }
      visit_filter = VisitFilter.new(filter)

      result = visit_filter.date_end_filter

      expect(result).to eq date
    end
  end

  describe "#visit_status_filter" do
    context "if :visit_status is present" do
      it "returns given :visit_status" do
        filter = { visit_status: "approved" }
        visit_filter = VisitFilter.new(filter)

        result = visit_filter.visit_status_filter

        expect(result).to eq "approved"
      end
    end

    context "if :visit_status is not present" do
      it "returns 'all'" do
        filter = { visit_status: "" }
        visit_filter = VisitFilter.new(filter)

        result = visit_filter.visit_status_filter

        expect(result).to eq VisitFilter::DEFAULT_VISIT_STATUS_FILTER
      end
    end
  end

  describe "#report_access_filter" do
    context "if :report_access is present" do
      it "returns given :report_access format as boolean" do
        filter = { report_access: "1" }
        visit_filter = VisitFilter.new(filter)

        result = visit_filter.report_access_filter

        expect(result).to eq true
      end
    end

    context "if :report_access is not present" do
      it "returns DEFAULT_REPORT_ACCESS_FILTER" do
        filter = { report_access: "" }
        visit_filter = VisitFilter.new(filter)

        result = visit_filter.report_access_filter

        expect(result).to eq VisitFilter::DEFAULT_REPORT_ACCESS_FILTER
      end
    end
  end
end
