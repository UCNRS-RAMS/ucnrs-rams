require "rails_helper"

RSpec.describe Manager::Visits::VisitsFormPresenter do
  let(:presenter) { Manager::Visits::VisitsFormPresenter.new(user: build(:user)) }

  describe "#project_type_partail_path" do
    it "should return project_type_partail_path" do
      expect(presenter.project_type_partail_path).to eq "manager/visits/detail/project_type"
    end
  end

  describe "#project_partail_path" do
    it "should return project_partail_path" do
      expect(presenter.project_partail_path).to eq "manager/visits/detail/project"
    end
  end

  describe "#save_partail_path" do
    it "should return save_partail_path" do
      expect(presenter.save_partail_path).to eq "manager/visits/detail/save"
    end
  end

  describe "#reserve_partail_path" do
    it "should return reserve_select_field_partial_path" do
      expect(presenter.reserve_partail_path).to eq "manager/visits/detail/reserve"
    end
  end

  describe "#show_browse_reserve_link" do
    it "should return false to hide browse reserve link" do
      expect(presenter.show_browse_reserve_link).to eq false
    end
  end
end