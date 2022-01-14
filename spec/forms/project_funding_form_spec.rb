require "rails_helper"

RSpec.describe ProjectFundingForm, type: :model do
  describe "delegations" do
    it { is_expected.to delegate_method(:valid?).to(:funding) }
    it { is_expected.to delegate_method(:validate).to(:funding) }
    it { is_expected.to delegate_method(:errors).to(:funding) }
    it { is_expected.to delegate_missing_methods_to(:funding) }
  end

  describe "initializing" do
    it "makes an empty ProjectFundingForm from empty params" do
      form = ProjectFundingForm.new(params: {})

      expect(form).to have_attributes(
        title: nil,
        is_funded: "0",
        is_submitted: "0",
        will_be_submitted: "0",
        was_denied: "0",
        principal_investigators: nil,
        co_principal_investigators: nil,
        start_date: nil,
        end_date: nil,
        sponsor: nil,
        sponsor_other: nil,
        award_amount: nil,
        grant_number: nil,
        funding_opportunity_number: nil,
      )
    end

    it "makes a new ProjectFundingForm from params" do
      project = build_stubbed(:project)
      params = {
        title: "Money, just for you!",
        is_funded: "0",
        is_submitted: "1",
        will_be_submitted: "0",
        was_denied: "0",
        principal_investigators: "Mister Moustache,Missus Moustache",
        co_principal_investigators: nil,
        start_date: Date.new(2022, 1, 1),
        end_date: Date.new(2023, 1, 1),
        sponsor: :other,
        sponsor_other: "Some other sponsor",
        award_amount: "1000000.00",
        grant_number: "G123",
        funding_opportunity_number: "FON123",
      }
      form = ProjectFundingForm.new(project: project, params: params)

      expect(form).to have_attributes(
        title: "Money, just for you!",
        is_funded: "0",
        is_submitted: "1",
        will_be_submitted: "0",
        was_denied: "0",
        principal_investigators: "Mister Moustache,Missus Moustache",
        co_principal_investigators: nil,
        start_date: Date.new(2022, 1, 1),
        end_date: Date.new(2023, 1, 1),
        sponsor: "other",
        sponsor_other: "Some other sponsor",
        award_amount: 1000000.0,
        grant_number: "G123",
        funding_opportunity_number: "FON123",
      )
    end
  end

  describe "#save" do
    it "saves the funding if there are no errors" do
      project = create(:project)
      form = ProjectFundingForm.new(project: project, params: {
        title: "Money, just for you!",
        is_funded: "0",
        is_submitted: "1",
        will_be_submitted: "0",
        was_denied: "0",
        principal_investigators: "Mister Moustache,Missus Moustache",
        co_principal_investigators: nil,
        start_date: Date.new(2022, 1, 1),
        end_date: Date.new(2023, 1, 1),
        sponsor: :other,
        sponsor_other: "Some other sponsor",
        award_amount: "1000000.00",
        grant_number: "G123",
        funding_opportunity_number: "FON123",
      })

      result = form.save

      expect(result).to be_truthy
      expect(form.funding).to be_persisted
      expect(form.funding).to have_attributes(
        title: "Money, just for you!",
        is_funded: false,
        is_submitted: true,
        will_be_submitted: false,
        was_denied: false,
        principal_investigators: "Mister Moustache,Missus Moustache",
        co_principal_investigators: nil,
        start_date: Date.new(2022, 1, 1),
        end_date: Date.new(2023, 1, 1),
        sponsor: "other",
        sponsor_other: "Some other sponsor",
        award_amount: 1000000.0,
        grant_number: "G123",
        funding_opportunity_number: "FON123",
        project_id: project.id,
      )
    end

    it "makes sure errors are visible when save fails" do
      project = create(:project)
      form = ProjectFundingForm.new(project: project, params: {})

      result = form.save

      expect(result).to be_falsy
      expect(form.funding).to_not be_persisted
      expect(form.errors).to be_present
    end
  end

  describe "#is_funded" do
    it "is '1' if the funding is funded" do
      funding = create(:funding, is_funded: true)
      form = form = ProjectFundingForm.new(params: { id: funding.id })

      expect(form.is_funded).to eq "1"
    end

    it "is '0' if the funding is not funded" do
      funding = create(:funding, is_funded: false)
      form = form = ProjectFundingForm.new(params: { id: funding.id })

      expect(form.is_funded).to eq "0"
    end
  end

  describe "#is_submitted" do
    it "is '1' if the funding is submitted" do
      funding = create(:funding, is_submitted: true)
      form = form = ProjectFundingForm.new(params: { id: funding.id })

      expect(form.is_submitted).to eq "1"
    end

    it "is '0' if the funding is not submitted" do
      funding = create(:funding, is_submitted: false)
      form = form = ProjectFundingForm.new(params: { id: funding.id })

      expect(form.is_submitted).to eq "0"
    end
  end

  describe "#will_be_submitted" do
    it "is '1' if the funding will be submitted" do
      funding = create(:funding, will_be_submitted: true)
      form = form = ProjectFundingForm.new(params: { id: funding.id })

      expect(form.will_be_submitted).to eq "1"
    end

    it "is '0' if the funding will not be submitted" do
      funding = create(:funding, will_be_submitted: false)
      form = form = ProjectFundingForm.new(params: { id: funding.id })

      expect(form.will_be_submitted).to eq "0"
    end
  end

  describe "#was_denied" do
    it "is '1' if the funding was denied" do
      funding = create(:funding, was_denied: true)
      form = form = ProjectFundingForm.new(params: { id: funding.id })

      expect(form.was_denied).to eq "1"
    end

    it "is '0' if the funding was not denied" do
      funding = create(:funding, was_denied: false)
      form = form = ProjectFundingForm.new(params: { id: funding.id })

      expect(form.was_denied).to eq "0"
    end
  end
end
