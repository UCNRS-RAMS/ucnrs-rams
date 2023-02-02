require "rails_helper"

RSpec.describe Manager::ReserveInfo::ReserveTagsPresenter do
  describe "#reserve_tags" do
    it "return reserves tags array" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      reserve3 = create(:reserve)
      reserve4 = create(:reserve)
      reserve_tag1 = create(:reserve_tag, reserve: reserve1, category: :geographic, name: "River")
      reserve_tag2 = create(:reserve_tag, reserve: reserve2, category: :ecosystem, name: "Marsh")
      reserve_tag3 = create(:reserve_tag, reserve: reserve3, category: :geographic, name: "Dunes")
      reserve_tag4 = create(:reserve_tag, reserve: reserve4, category: :amenities, name: "Beach")

      presenter = Manager::ReserveInfo::ReserveTagsPresenter.new(reserve: reserve1)

      output = {"geographic"=>["River", "Dunes"], "ecosystem"=>["Marsh"], "amenities"=>["Beach"]}

      expect(presenter.reserve_tags).to eq output
    end
  end

  describe "#has_reserve_tag?" do
    it "return true if reserve has reserve_tag with given category and name" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      reserve_tag1 = create(:reserve_tag, reserve: reserve1, category: :geographic, name: "River")
      reserve_tag2 = create(:reserve_tag, reserve: reserve2, category: :ecosystem, name: "Marsh")

      presenter = Manager::ReserveInfo::ReserveTagsPresenter.new(reserve: reserve1)

      expect(presenter.has_reserve_tag?("geographic", "River")).to be_truthy
    end

    it "return false if reserve has no reserve_tag with given category and name" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      reserve_tag1 = create(:reserve_tag, reserve: reserve1, category: :geographic, name: "River")
      reserve_tag2 = create(:reserve_tag, reserve: reserve2, category: :ecosystem, name: "Marsh")

      presenter = Manager::ReserveInfo::ReserveTagsPresenter.new(reserve: reserve1)

      expect(presenter.has_reserve_tag?("ecosystem", "River")).to be_falsy
    end
  end
end
