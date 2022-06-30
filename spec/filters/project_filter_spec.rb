require "rails_helper"

RSpec.describe ProjectFilter do
  describe "#project_search_filter" do
    context "if :sort_by is present" do
      it "returns a strip :project_search" do
        filter = { project_search: "  keyword  " }
        project_filter = ProjectFilter.new(filter, nil)

        result = project_filter.project_search_filter
    
        expect(result).to eq "keyword"
      end
    end

    context "if :sort_by is not present" do
      it "returns a strip :project_search" do
        filter = { project_search: "" }
        project_filter = ProjectFilter.new(filter, nil)

        result = project_filter.project_search_filter
    
        expect(result).to eq ""
      end
    end
  end

  describe "#sort_by_filter" do
    context "if :sort_by is present" do
      it "returns :sort_by" do
        filter = { sort_by: "keyword" }
        project_filter = ProjectFilter.new(filter, nil)

        result = project_filter.sort_by_filter
    
        expect(result).to eq "keyword"
      end
    end

    context "if :sort_by is not present" do
      it "returns 'submitted_recent_first'" do
        filter = { sort_by: "" }
        project_filter = ProjectFilter.new(filter, nil)

        result = project_filter.sort_by_filter
    
        expect(result).to eq "submitted_recent_first"
      end
    end
  end

  describe "#reserve_filter" do
    context "if :filter is nil" do
      it "returns given reserve.id" do
        filter = { reserve: nil }
        reserve = create(:reserve)
        project_filter = ProjectFilter.new(filter, reserve)

        result = project_filter.reserve_filter
    
        expect(result).to eq reserve.id
      end
    end

    context "if :filter is not nil" do
      it "returns :filter" do
        filter = { reserve: "1" }
        project_filter = ProjectFilter.new(filter, nil)

        result = project_filter.reserve_filter
    
        expect(result).to eq "1"
      end
    end
  end

  describe "#date_range_type_filter" do
    it "returns :date_range_type" do
      filter = { date_range_type: "range type" }
      project_filter = ProjectFilter.new(filter, nil)

      result = project_filter.date_range_type_filter
  
      expect(result).to eq "range type"
    end
  end

  describe "#project_type_filter" do
    context "if :project_type is present" do
      it "returns given :project_type" do
        filter = { project_type: "a project type" }
        project_filter = ProjectFilter.new(filter, nil)

        result = project_filter.project_type_filter
    
        expect(result).to eq "a project type"
      end
    end

    context "if :project_type is not present" do
      it "returns 'all'" do
        filter = { project_type: "" }
        project_filter = ProjectFilter.new(filter, nil)

        result = project_filter.project_type_filter
    
        expect(result).to eq 'all'
      end
    end
  end

  describe "#date_begin_filter" do
    it "returns :date_begin" do
      filter = { date_begin: "a date" }
      project_filter = ProjectFilter.new(filter, nil)

      result = project_filter.date_begin_filter
  
      expect(result).to eq "a date"
    end
  end

  describe "#date_end_filter" do
    it "returns :date_end" do
      filter = { date_end: "a date" }
      project_filter = ProjectFilter.new(filter, nil)

      result = project_filter.date_end_filter
  
      expect(result).to eq "a date"
    end
  end

  describe "#project_status_filter" do
    context "if :project_status is present" do
      it "returns given :project_status" do
        filter = { project_status: "a project type" }
        project_filter = ProjectFilter.new(filter, nil)

        result = project_filter.project_status_filter
    
        expect(result).to eq "a project type"
      end
    end

    context "if :project_status is not present" do
      it "returns 'all'" do
        filter = { project_status: "" }
        project_filter = ProjectFilter.new(filter, nil)

        result = project_filter.project_status_filter
    
        expect(result).to eq Project::ALL_FILTER
      end
    end
  end
end
