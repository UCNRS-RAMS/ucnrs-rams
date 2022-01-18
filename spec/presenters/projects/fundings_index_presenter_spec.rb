require "rails_helper"

RSpec.describe Projects::FundingsIndexPresenter do
  describe "delegations" do
    subject { Projects::FundingsIndexPresenter.new(current_step: 4, project: build_stubbed(:project)) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
  end

  describe "#sponsor_options" do
    it "is a list of funding sponsors" do
      presenter = Projects::FundingsIndexPresenter.new(
        current_step: 4,
        project: build_stubbed(:project),
      )

      expect(presenter.sponsor_options).to eq [
        [
          "National Science Foundation (NSF)",
          "national_science_foundation",
        ],
       [
          "National Institute of Health (NIH)",
          "national_institute_of_health",
        ],
        [
          "U.S. Geological Survey (USGS)",
          "us_geological_survey",
        ],
        [
          "U.S. Forest Service (USFS)",
          "us_forest_service",
        ],
        [
          "U.S. Department of Agriculture (USDA)",
          "us_dept_of_agriculture",
        ],
        [
          "California Department of Fish and Wildlife",
          "ca_dept_of_fish_and_wildlife",
        ],
        [
          "Other",
          "other",
        ],
      ]
    end
  end

  describe "#fundings" do
    it "creates a FundingPresenter for each funding" do
      project = create(:project)
      create(:funding, title: "Funding C", project: project)
      create(:funding, title: "Funding A", project: project)
      create(:funding, title: "Funding B", project: project)
      create(:funding)
      presenter = Projects::FundingsIndexPresenter.new(
        current_step: 4,
        project: project,
      )

      results = presenter.fundings

      expect(results.map(&:title)).to eq [
        "Funding A",
        "Funding B",
        "Funding C",
      ]
    end
  end
end
