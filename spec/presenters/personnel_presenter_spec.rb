require "rails_helper"

RSpec.describe PersonnelPresenter do
  describe "delegations" do
    subject { PersonnelPresenter.new(build(:reserve_personnel)) }
    it { is_expected.to delegate_method(:full_name).to(:user).with_prefix(true) }
    it { is_expected.to delegate_method(:user).to(:personnel) }
    it { is_expected.to delegate_missing_methods_to(:personnel) }
  end

  describe "#icon" do
    context "when the supplied value is true" do
      it "is the check icon" do
        reserve_personnel = create(:reserve_personnel)
        presenter = PersonnelPresenter.new(reserve_personnel)

        expect(presenter.icon(true)).to eq "check.svg"
      end
    end

    context "when the supplied value is false" do
      it "is the uncheck icon" do
        reserve_personnel = create(:reserve_personnel)
        presenter = PersonnelPresenter.new(reserve_personnel)

        expect(presenter.icon(false)).to eq "dot.svg"
      end
    end
  end

  describe "#icon_alt_i18n_key" do
    it "returns the key into the translations for a checked icon" do
      reserve_personnel = create(:reserve_personnel)
      presenter = PersonnelPresenter.new(reserve_personnel)

      expect(presenter.icon_alt_i18n_key(true)).to eq "alt.checked"
    end

    it "returns the key into the translations for an unchecked icon" do
      reserve_personnel = create(:reserve_personnel)
      presenter = PersonnelPresenter.new(reserve_personnel)

      expect(presenter.icon_alt_i18n_key(false)).to eq "alt.unchecked"
    end
  end
end
