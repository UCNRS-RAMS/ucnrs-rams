require "rails_helper"

RSpec.describe Manager::Reports::ReportPart1RowPresenter do
  describe "delegations" do
    subject { Manager::Reports::ReportPart1RowPresenter.new(:row) }
    it { is_expected.to delegate_missing_methods_to(:row) }
  end

  describe "#role" do
    it "returns the translated name of the row role value" do
      allow(User).to receive(:roles).and_return({
        "key1" => "value1",
      })
      allow(I18n).to receive(:t)
        .with("universal.roles.key1")
        .and_return("role_key1_translate")
      row = { "role" => "value1" }
      presenter = Manager::Reports::ReportPart1RowPresenter.new(row)

      result = presenter.role

      expect(result).to eq "role_key1_translate"
    end
  end

  describe "#user_role_key" do
    it "returns the key of the given user role value" do
      allow(User).to receive(:roles).and_return({
        "key1" => "value1",
      })
      row = { "role" => "value1" }
      presenter = Manager::Reports::ReportPart1RowPresenter.new(row)

      result = presenter.user_role_key

      expect(result).to eq "key1"
    end
  end
end
