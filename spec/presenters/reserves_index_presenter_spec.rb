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
      index_presenter = ReservesIndexPresenter.new

      output = ["ecosystem", "geographic", "organization", "amenities", "internet", "other", "facility"]

      expect(index_presenter.reserve_tags).to eq output
    end
  end
end
