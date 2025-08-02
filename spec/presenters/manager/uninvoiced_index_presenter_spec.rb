require "rails_helper"

RSpec.describe Manager::UninvoicedIndexPresenter do
  describe "#visits" do
    it "presents the visit records wrapped in VisitPresenter" do
      reserve = create(:reserve)
      visit1 = create(:visit, reserve: reserve, status: :approved)
      visit2 = create(:visit, reserve: reserve, status: :approved)
      create(:visit, reserve: reserve)
      create(:visit)
      create(:amenity_visit, visit: visit1, invoice_id: nil)
      create(:amenity_visit, visit: visit2, invoice_id: nil)

      presenter = Manager::UninvoicedIndexPresenter.new(reserve: reserve)

      expect(presenter.visits.map(&:id)).to match_array [visit1.id, visit2.id]
      expect(presenter.visits).to all(be_a(VisitPresenter))
    end
  end

  describe "#visit_scope" do
    it "only returns visits on the given reserve" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      visit1 = create(:visit, reserve: reserve1, status: :approved)
      visit2 = create(:visit, reserve: reserve1, status: :approved)
      visit3 = create(:visit, reserve: reserve2, status: :approved)
      create(:amenity_visit, visit: visit1, invoice_id: nil)
      create(:amenity_visit, visit: visit2, invoice_id: nil)
      create(:amenity_visit, visit: visit3, invoice_id: nil)
      presenter = Manager::UninvoicedIndexPresenter.new(reserve: reserve1)

      scope = presenter.visit_scope

      expect(scope).to match_array [visit1, visit2]
    end

    it "returns a maximum of 10 visits" do
      reserve = create(:reserve)
      create_list(:visit, 11, reserve: reserve, status: :approved) do |visit|
        create(:amenity_visit, visit: visit, invoice_id: nil)
      end
      presenter = Manager::UninvoicedIndexPresenter.new(reserve: reserve)

      scope = presenter.visit_scope

      expect(scope.length).to eq 10
    end

    it "returns only approved visits" do
      reserve = create(:reserve)
      visit1 = create(:visit, reserve: reserve, status: :approved)
      visit2 = create(:visit, reserve: reserve, status: :approved)
      visit3 = create(:visit, reserve: reserve, status: :in_review)
      create(:amenity_visit, visit: visit1, invoice_id: nil)
      create(:amenity_visit, visit: visit2, invoice_id: nil)
      create(:amenity_visit, visit: visit3, invoice_id: nil)
      presenter = Manager::UninvoicedIndexPresenter.new(reserve: reserve)

      scope = presenter.visit_scope

      expect(scope).to match_array [visit1, visit2]
    end

    it "returns only visits with uninvoiced amenities" do
      reserve = create(:reserve)
      visit1 = create(:visit, reserve: reserve, status: :approved)
      visit2 = create(:visit, reserve: reserve, status: :approved)
      visit3 = create(:visit, reserve: reserve, status: :approved)
      invoice1 = create(:invoice, visit: visit1)
      invoice2 = create(:invoice, visit: visit3)
      create(:amenity_visit, visit: visit1, invoice: invoice1)
      create(:amenity_visit, visit: visit2, invoice_id: nil)
      create(:amenity_visit, visit: visit3, invoice: invoice2)
      presenter = Manager::UninvoicedIndexPresenter.new(reserve: reserve)

      scope = presenter.visit_scope

      expect(scope).to match_array [visit2]
    end

    it "returns only visits not with never invoice amenities" do
      reserve = create(:reserve)
      visit1 = create(:visit, reserve: reserve, status: :approved)
      visit2 = create(:visit, reserve: reserve, status: :approved)
      visit3 = create(:visit, reserve: reserve, status: :approved)
      create(:amenity_visit, visit: visit1, invoice_id: nil, invoice_now: false)
      create(:amenity_visit, visit: visit2, invoice_id: nil, invoice_now: true)
      create(:amenity_visit, visit: visit3, invoice_id: nil, invoice_now: true)
      presenter = Manager::UninvoicedIndexPresenter.new(reserve: reserve)

      scope = presenter.visit_scope

      expect(scope).to match_array [visit2, visit3]
    end
  end
end
