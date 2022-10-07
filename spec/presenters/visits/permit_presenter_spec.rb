require "rails_helper"

RSpec.describe Visits::PermitPresenter do
  describe "delegations" do
    subject { Visits::PermitPresenter.new(build(:permit)) }
    it { is_expected.to delegate_missing_methods_to(:permit) }
  end

  describe "#render_values" do
    it "is a hash containing a path to the partial and locals" do
      presenter = Visits::PermitPresenter.new(build_stubbed(:permit))

      expect(presenter.render_values).to eq ({
        partial: "visits/questions/permit",
        locals: { permit: presenter },
      })
    end
  end

  describe "#urls" do
    it "returns a hash of urls and their descriptions" do
      permit = create(
        :permit,
        url1: "www.foo1.com",
        url1_description: "Foo 1",
        url2: "www.foo2.com",
        url2_description: "Foo 2",
        url3: "www.foo3.com",
        url3_description: "Foo 3",
      )
      presenter = Visits::PermitPresenter.new(permit)

      expect(presenter.urls).to include(
        "www.foo1.com" => "Foo 1",
        "www.foo2.com" => "Foo 2",
        "www.foo3.com" => "Foo 3",
      )
    end

    it "does not include the key/value pair if the url and descriptions are nil" do
      permit = create(
        :permit,
        url1: "www.foo1.com",
        url1_description: "Foo 1",
        url2: nil,
        url2_description: nil,
        url3: "www.foo3.com",
        url3_description: "Foo 3",
      )
      presenter = Visits::PermitPresenter.new(permit)

      expect(presenter.urls).to include(
        "www.foo1.com" => "Foo 1",
        "www.foo3.com" => "Foo 3",
      )
    end
  end

  describe "#answer" do
    it "the permit has an answer, it returns that" do
      permit = create(:permit)
      mock_permit_answer(permit, "1")

      presenter = Visits::PermitPresenter.new(permit)

      expect(presenter.answer).to eq "1"
    end

    it "returns '0' if the permit has no answer" do
      permit = create(:permit)

      presenter = Visits::PermitPresenter.new(permit)

      expect(presenter.answer).to eq "0"
    end
  end
end
