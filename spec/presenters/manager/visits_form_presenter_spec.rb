require "rails_helper"

RSpec.describe Manager::Visits::VisitsFormPresenter do
  let(:presenter) { Manager::Visits::VisitsFormPresenter.new(user: build(:user)) }

  describe "#project_type_partial_path" do
    it "should return project_type_partial_path" do
      expect(presenter.project_type_partial_path).to eq "manager/visits/detail/project_type"
    end
  end

  describe "#project_partial_path" do
    it "should return project_partial_path" do
      expect(presenter.project_partial_path).to eq "manager/visits/detail/project"
    end
  end

  describe "#save_partial_path" do
    it "should return save_partial_path" do
      expect(presenter.save_partial_path).to eq "manager/visits/detail/save"
    end
  end

  describe "#reserve_partial_path" do
    it "should return reserve_select_field_partial_path" do
      expect(presenter.reserve_partial_path).to eq "manager/visits/detail/reserve"
    end
  end

  describe "#show_browse_reserve_link" do
    it "should return false to hide browse reserve link" do
      expect(presenter.show_browse_reserve_link).to eq false
    end
  end

  describe "#amenities_by_group_label" do
    let(:reserve) { create(:reserve, amenity_group_label_1: "Label 1", amenity_group_label_2: "Label 2") }
    let(:visit) { create(:visit, reserve: reserve) }
    let(:user) { create(:user) }

    it "should return amenity group labels as keys" do
      create(:amenity, reserve: reserve, group_number: "1")
      create(:amenity, reserve: reserve, group_number: "2")

      form = VisitForm.new(user: user, params: { id: visit.id })
      presenter = Manager::Visits::VisitsFormPresenter.new(user: user, form: form)

      expect(presenter.amenities_by_group_label.keys).to eq ["Label 1", "Label 2"]
    end

    it "should return amenity group labels for amenities which are not disabled as keys" do
      create(:amenity, reserve: reserve, group_number: "1", disable: true)
      create(:amenity, reserve: reserve, group_number: "2", disable: false)

      form = VisitForm.new(user: user, params: {
        id: visit.id,
      })
      presenter = Manager::Visits::VisitsFormPresenter.new(user: user, form: form)

      expect(presenter.amenities_by_group_label.keys).to eq ["Label 2"]
    end
  end
end
