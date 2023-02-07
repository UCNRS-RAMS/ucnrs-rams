require "rails_helper"

RSpec.describe Manager::ReserveInfo::ReserveTagsNewPresenter do
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

      presenter = Manager::ReserveInfo::ReserveTagsNewPresenter.new(reserve: reserve1)

      output = {"geographic"=>[{:name=>"River", :value=>true}, {:name=>"Dunes", :value=>false}], "ecosystem"=>[{:name=>"Marsh", :value=>false}], "amenities"=>[{:name=>"Beach", :value=>false}]}

      expect(presenter.reserve_tags).to eq output
    end
  end
end
