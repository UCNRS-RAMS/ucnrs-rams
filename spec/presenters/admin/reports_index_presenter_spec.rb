require "rails_helper"

RSpec.describe Admin::ReportsIndexPresenter do
  describe "#annual_reports" do
    it "is the annual reports ordered by reserve pulldown name" do
      travel_to Time.zone.local(2025, 5, 5)
      reserve2 = create(:reserve, id: 1, pulldown_name: "reserve 2")
      reserve1 = create(:reserve, id: 3, pulldown_name: "reserve 1")
      reserve3 = create(:reserve, id: 2, pulldown_name: "reserve 3")
      create(:annual_report, reserve: reserve1, fiscal_year_ending: 2025)
      create(:annual_report, reserve: reserve2, fiscal_year_ending: 2025)
      create(:annual_report, reserve: reserve3, fiscal_year_ending: 2025)
      presenter = Admin::ReportsIndexPresenter.new(fiscal_year_ending: 2025)

      annual_reports = presenter.annual_reports

      expect(annual_reports.map { |report| report.reserve.pulldown_name })
        .to eq ["reserve 1", "reserve 2", "reserve 3"]
    end

    it "excludes reports from other fiscal years" do
      travel_to Time.zone.local(2025, 5, 5)
      reserve = create(:reserve, id: 1)
      requested_report = create(:annual_report, reserve: reserve, fiscal_year_ending: 2025)
      create(:annual_report, reserve: reserve, fiscal_year_ending: 2024)
      presenter = Admin::ReportsIndexPresenter.new(fiscal_year_ending: 2025)

      annual_reports = presenter.annual_reports

      expect(annual_reports).to eq [requested_report]
    end

    it "excludes reports for reserves outside of the system reserve ids" do
      travel_to Time.zone.local(2025, 5, 5)
      system_reserve = create(:reserve, id: 100)
      other_reserve = create(:reserve, id: 101)
      system_report = create(:annual_report, reserve: system_reserve, fiscal_year_ending: 2025)
      create(:annual_report, reserve: other_reserve, fiscal_year_ending: 2025)
      presenter = Admin::ReportsIndexPresenter.new(fiscal_year_ending: 2025)

      annual_reports = presenter.annual_reports

      expect(annual_reports).to eq [system_report]
    end

    it "is empty when no reports exist for the fiscal year" do
      travel_to Time.zone.local(2025, 5, 5)
      reserve = create(:reserve, id: 1)
      create(:annual_report, reserve: reserve, fiscal_year_ending: 2024)
      presenter = Admin::ReportsIndexPresenter.new(fiscal_year_ending: 2025)

      annual_reports = presenter.annual_reports

      expect(annual_reports).to be_empty
    end
  end

  describe "#labeled_designated_fiscal_year" do
    it "is the label for the fiscal year ending" do
      travel_to Time.zone.local(2025, 5, 5)
      presenter = Admin::ReportsIndexPresenter.new(fiscal_year_ending: 2025)

      labeled_designated_fiscal_year = presenter.labeled_designated_fiscal_year

      expect(labeled_designated_fiscal_year).to eq "2024-2025"
    end
  end

  describe "#designated_fiscal_year_ending" do
    it "is the requested fiscal year ending" do
      travel_to Time.zone.local(2025, 5, 5)
      presenter = Admin::ReportsIndexPresenter.new(fiscal_year_ending: 2020)

      designated_fiscal_year_ending = presenter.designated_fiscal_year_ending

      expect(designated_fiscal_year_ending).to eq 2020
    end

    it "casts a requested fiscal year ending given as a string" do
      travel_to Time.zone.local(2025, 5, 5)
      presenter = Admin::ReportsIndexPresenter.new(fiscal_year_ending: "2020")

      designated_fiscal_year_ending = presenter.designated_fiscal_year_ending

      expect(designated_fiscal_year_ending).to eq 2020
    end

    it "is the default fiscal year ending when none is requested" do
      travel_to Time.zone.local(2025, 5, 5)
      presenter = Admin::ReportsIndexPresenter.new

      designated_fiscal_year_ending = presenter.designated_fiscal_year_ending

      expect(designated_fiscal_year_ending).to eq 2025
    end

    it "is the default fiscal year ending when the requested one is before the first one" do
      travel_to Time.zone.local(2025, 5, 5)
      presenter = Admin::ReportsIndexPresenter.new(fiscal_year_ending: 2014)

      designated_fiscal_year_ending = presenter.designated_fiscal_year_ending

      expect(designated_fiscal_year_ending).to eq 2025
    end

    it "is the default fiscal year ending when the requested one is in the future" do
      travel_to Time.zone.local(2025, 5, 5)
      presenter = Admin::ReportsIndexPresenter.new(fiscal_year_ending: 2026)

      designated_fiscal_year_ending = presenter.designated_fiscal_year_ending

      expect(designated_fiscal_year_ending).to eq 2025
    end

    it "is the default fiscal year ending when the requested one is not a number" do
      travel_to Time.zone.local(2025, 5, 5)
      presenter = Admin::ReportsIndexPresenter.new(fiscal_year_ending: "not a year")

      designated_fiscal_year_ending = presenter.designated_fiscal_year_ending

      expect(designated_fiscal_year_ending).to eq 2025
    end
  end

  describe "#fiscal_year_ending_options" do
    it "is a label and year for every fiscal year from the default one back to 2015" do
      travel_to Time.zone.local(2025, 5, 5)
      presenter = Admin::ReportsIndexPresenter.new

      fiscal_year_ending_options = presenter.fiscal_year_ending_options

      expected_options = 2025.downto(2015).map do |year_ending|
        ["#{year_ending - 1}-#{year_ending}", year_ending]
      end

      expect(fiscal_year_ending_options.first).to eq ["2024-2025", 2025]
      expect(fiscal_year_ending_options.last).to eq ["2014-2015", 2015]
      expect(fiscal_year_ending_options).to eq expected_options
    end
  end
end
