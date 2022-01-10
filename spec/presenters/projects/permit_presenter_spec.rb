require "rails_helper"

RSpec.describe Projects::PermitPresenter do
  describe "delegations" do
    subject { Projects::PermitPresenter.new(build(:permit)) }
    it { is_expected.to delegate_missing_methods_to(:permit) }
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
      presenter = Projects::PermitPresenter.new(permit)

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
      presenter = Projects::PermitPresenter.new(permit)

      expect(presenter.urls).to include(
        "www.foo1.com" => "Foo 1",
        "www.foo3.com" => "Foo 3",
      )
    end
  end
end
