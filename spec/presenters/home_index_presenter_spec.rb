require "rails_helper"

RSpec.describe HomeIndexPresenter do
  let(:user) { create(:user, :confirmed) }

  describe "#visit_filter_options" do
    it "generates a date range" do
      presenter = HomeIndexPresenter.new(user: user)
      output = { "approved"=>"approved", "in_review"=>"in_review", "cancelled"=>"cancelled", "incomplete"=>"incomplete", "denied"=>"denied" }

      expect(presenter.visit_filter_options).to eq output
    end
  end

  describe "#invoice_filter_options" do
    it "generates a date range" do
      presenter = HomeIndexPresenter.new(user: user)
      output = { "Recent Invoices" => nil, "Paid" => :paid, "Balance Due" => :due }

      expect(presenter.invoice_filter_options).to eq output
    end
  end

  describe "#invoice_reserve_list" do
    it "generates hash of reserves name and id" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      invoice1 = create(:invoice, visit: create(:visit, reserve: reserve1))
      invoice2 = create(:invoice, visit: create(:visit, reserve: reserve2))
      create(:invoice_recipient, user: user, invoice: invoice1)
      create(:invoice_recipient, user: user, invoice: invoice2)

      presenter = HomeIndexPresenter.new(user: user)
      output = { reserve1.name => reserve1.id, reserve2.name => reserve2.id }

      expect(presenter.invoice_reserve_list).to eq output
    end
  end

  describe "#calendar_button_class" do
    it "returns 'inactive' class" do
      presenter = HomeIndexPresenter.new(user: user)

      output = "inactive"

      expect(presenter.calendar_button_class).to eq output
    end
  end

  describe "#list_button_class" do
    it "returns 'active' class" do
      presenter = HomeIndexPresenter.new(user: user)

      output = "active"

      expect(presenter.list_button_class).to eq output
    end
  end

  describe "#invoice_selected" do
    it "return 'selected' if invoice_filter is equal to given option" do
      presenter = HomeIndexPresenter.new(user: user, invoice_filter: "status" )
      output = "selected"

      expect(presenter.invoice_selected("status")).to eq output
    end

    it "return '' if invoice_filter is not equal to given option" do
      presenter = HomeIndexPresenter.new(user: user, invoice_filter: "status" )
      output = ""

      expect(presenter.invoice_selected("reserve")).to eq output
    end
  end

  describe "#visit_selected" do
    it "return 'selected' if visit_filter is equal to given option" do
      presenter = HomeIndexPresenter.new(user: user, visit_filter: "status" )
      output = "selected"

      expect(presenter.visit_selected("status")).to eq output
    end

    it "return '' if visit_filter is not equal to given option" do
      presenter = HomeIndexPresenter.new(user: user, invoice_filter: "status" )
      output = ""

      expect(presenter.visit_selected("reserve")).to eq output
    end
  end

  describe "#visit_scope" do
    context "if visit_filter is reserve" do
      it "return visits where reserve_id is equal to visit's reserve_id" do
        reserve = create(:reserve)
        visit1 = create(:visit, user: user, reserve: reserve)
        visit2 = create(:visit, user: user)
        create(:user_visit, visit: visit1, user: user)
        create(:user_visit, visit: visit2, user: user)

        presenter = HomeIndexPresenter.new(user: user, visit_filter: "reserve_#{reserve.id}")

        expect(presenter.visit_scope).to match_array [visit1]
      end
    end

    context "if visit_filter is status" do
      it "return visits where visit status approved" do
        reserve = create(:reserve)
        visit1 = create(:visit, user: user, status: "approved")
        visit2 = create(:visit, user: user)
        create(:user_visit, visit: visit1, user: user)
        create(:user_visit, visit: visit2, user: user)

        presenter = HomeIndexPresenter.new(user: user, visit_filter: "approved")

        expect(presenter.visit_scope).to match_array [visit1]
      end
    end

    context "if visit_filter is nil" do
      it "return all visits" do
        reserve = create(:reserve)
        visit1 = create(:visit, user: user)
        visit2 = create(:visit, user: user)
        create(:user_visit, visit: visit1, user: user)
        create(:user_visit, visit: visit2, user: user)

        presenter = HomeIndexPresenter.new(user: user)

        expect(presenter.visit_scope).to match_array [visit1, visit2]
      end
    end
  end

  describe "#visits" do
    context "if visit_filter is nil" do
      it "return array of visit presenters" do
        reserve = create(:reserve)
        visit1 = create(:visit, user: user)
        visit2 = create(:visit, user: user)
        create(:user_visit, visit: visit1, user: user)
        create(:user_visit, visit: visit2, user: user)

        presenter = HomeIndexPresenter.new(user: user)

        expect(presenter.visits).to all(be_instance_of VisitPresenter)
      end
    end
  end

  describe "#invoice_scope" do
    context "if invoice_filter is reserve" do
      it "return invoices where reserve_id is equal to visit's reserve_id" do
        reserve = create(:reserve)
        invoice1 = create(:invoice, visit: create(:visit, reserve: reserve))
        invoice2 = create(:invoice, visit: create(:visit, reserve: reserve))
        invoice3 = create(:invoice, visit: create(:visit))
        create(:invoice_recipient, user: user, invoice: invoice1)
        create(:invoice_recipient, user: user, invoice: invoice2)
        create(:invoice_recipient, user: user, invoice: invoice3)

        presenter = HomeIndexPresenter.new(user: user, invoice_filter: "reserve_#{reserve.id}")

        expect(presenter.invoice_scope).to match_array [invoice1, invoice2]
      end
    end

    context "if invoice_filter is status" do
      it "return invoices where invoice status is paid" do
        invoice1 = create(:invoice)
        invoice2 = create(:invoice, balance_due: 10)
        invoice3 = create(:invoice)
        create(:invoice_recipient, user: user, invoice: invoice1)
        create(:invoice_recipient, user: user, invoice: invoice2)
        create(:invoice_recipient, user: user, invoice: invoice3)

        presenter = HomeIndexPresenter.new(user: user, invoice_filter: "paid")

        expect(presenter.invoice_scope).to match_array [invoice1, invoice3]
      end
    end

    context "if invoice_filter is nil" do
      it "return all user invoices" do
        create(:invoice_recipient, user: user, invoice: create(:invoice))
        create(:invoice_recipient, user: user, invoice: create(:invoice))
        create(:invoice_recipient, user: user, invoice: create(:invoice))

        presenter = HomeIndexPresenter.new(user: user)

        expect(presenter.invoice_scope).to match_array(user.invoices.to_a)
      end
    end
  end
end
