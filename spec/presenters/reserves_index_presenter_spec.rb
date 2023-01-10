require "rails_helper"

RSpec.describe ReservesIndexPresenter do
  describe "#reserves" do
    context "if visit_filter is nil" do
      it "return array of reserve presenters" do
        reserve_one = create_list(:reserve, 3)

        index_presenter = ReservesIndexPresenter.new
        
        expect(index_presenter.reserves).to all(be_instance_of ReservePresenter)
      end
    end
  end

  describe "#reserve_tags" do
    it "return reserves tags array" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      reserve3 = create(:reserve)
      reserve4 = create(:reserve)
      reserve_tag1 = create(:reserve_tag, reserve: reserve1, tag_type: :geographic, name: "River")
      reserve_tag2 = create(:reserve_tag, reserve: reserve2, tag_type: :ecosystem, name: "Marsh")
      reserve_tag3 = create(:reserve_tag, reserve: reserve3, tag_type: :geographic, name: "Dunes")
      reserve_tag4 = create(:reserve_tag, reserve: reserve4, tag_type: :amenities, name: "Beach")

      index_presenter = ReservesIndexPresenter.new

      output = {"geographic"=>["River", "Dunes"], "ecosystem"=>["Marsh"], "amenities"=>["Beach"]}

      expect(index_presenter.reserve_tags).to eq output
    end
  end
end
