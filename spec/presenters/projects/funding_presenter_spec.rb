require "rails_helper"

RSpec.describe Projects::FundingPresenter do
  describe "delegations" do
    subject { Projects::FundingPresenter.new(build(:funding)) }
    it { is_expected.to delegate_method(:sponsor).to(:funding).with_prefix }
    it { is_expected.to delegate_method(:award_amount).to(:funding).with_prefix }
    it { is_expected.to delegate_missing_methods_to(:funding) }
  end

  describe "#sponsor" do
    it "is the human readable value for sponsor" do
      funding = build(:funding, sponsor: :national_science_foundation)
      presenter = Projects::FundingPresenter.new(funding)

      expect(presenter.sponsor).to eq("National Science Foundation (NSF)")
    end

    describe "when sponsor is 'other'" do
      it "is the value of sponsor_other" do
        funding = build(
          :funding,
          sponsor: :other,
          sponsor_other: "Foo U",
        )
        presenter = Projects::FundingPresenter.new(funding)
  
        expect(presenter.sponsor).to eq("Foo U")
      end
    end
  end

  describe "#award_amount" do
    it "is the funding's award amount formatted in USD" do
      funding = build(:funding, award_amount: 1000000.588)
      presenter = Projects::FundingPresenter.new(funding)

      expect(presenter.award_amount).to eq("$1,000,000.59")
    end
  end

  describe "#edit_funding_form_path" do
    it "returns the edit path for funding form" do
      funding = create(:funding)
      presenter = Projects::FundingPresenter.new(funding)

      expect(presenter.edit_funding_form_path).to eq("/fundings/#{funding.id}/edit")
    end
  end
end
