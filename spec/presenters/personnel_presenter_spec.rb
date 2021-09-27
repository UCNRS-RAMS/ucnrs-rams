require "rails_helper"

RSpec.describe PersonnelPresenter do
  describe "delegations" do
    subject { PersonnelPresenter.new(Personnel.new(1, "Suzanne Olyarnik", "Reserve Manager", 
      "(707) 875-2020)", "email1@example.com", "personnel1.jpg")) }
    it { is_expected.to delegate_method(:id).to(:personnel) }
    it { is_expected.to delegate_method(:name).to(:personnel) }
    it { is_expected.to delegate_method(:title).to(:personnel) }
    it { is_expected.to delegate_method(:phone).to(:personnel) }
    it { is_expected.to delegate_method(:email).to(:personnel) }
    it { is_expected.to delegate_method(:image).to(:personnel) }
  end
end
