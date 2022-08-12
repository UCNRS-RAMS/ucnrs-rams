require "rails_helper"

RSpec.describe UserVisitForm, type: :model do
  describe "validations" do
    describe "edit" do
      let(:visit) { create(:visit, start_date: 3.months.ago) }
      let(:user_visit) { create(:user_visit, visit: visit) }
      subject { UserVisitForm.new(params: { id: user_visit.id }) }

      it { is_expected.to validate_presence_of(:arrives_at) }
      it { is_expected.to validate_presence_of(:departs_at) }
    end
  end

  describe "when validating params" do
    it "collates errors when saving an existing user_visit" do
      user_visit = create(:user_visit)
      form = UserVisitForm.new(params: { id: user_visit.id, institution_id: nil, arrives_at: nil })

      form.validate

      expect(form.errors[:institution_id]).to eq ["can't be blank"]
      expect(form.errors[:arrives_at]).to eq ["can't be blank"]
    end

    it "does not allow users that don't exist" do
      user_visit = create(:user_visit)
      form = UserVisitForm.new(
        params: {
          id: user_visit.id,
          user_id: 234_725_874_837_538_745,
        },
      )

      form.validate

      expect(form.errors[:user]).to eq ["must exist"]
    end

    it "does not allow visits that don't exist" do
      user_visit = create(:user_visit)
      form = UserVisitForm.new(
        params: {
          id: user_visit.id,
          visit_id: 234_725_874_837_538_745,
        },
      )

      form.validate

      expect(form.errors[:visit]).to eq ["must exist"]
    end

    it "does not allow institutions that don't exist" do
      user_visit = create(:user_visit)
      form = UserVisitForm.new(
        params: {
          id: user_visit.id,
          institution_id: 234_725_874_837_538_745,
        },
      )

      form.validate

      expect(form.errors[:institution]).to eq ["must exist"]
    end
  end

  describe "initialize" do
    it "tries to load the UserVisit with id of params[:id]" do
      user_visit = create(:user_visit)

      form = UserVisitForm.new(
        params: { id: user_visit.id },
      )

      expect(form.user_visit).to eq user_visit
    end

    it "initializes a new UserVisit if the id is not available" do
      form = UserVisitForm.new(
      params: { id: -1 },
    )

      expect(form.user_visit).to_not be_persisted
    end
  end

  describe "delegations" do
    subject { UserVisitForm.new(params: { id: build(:user_visit).id }) }
    it { is_expected.to delegate_missing_methods_to(:user_visit) }
  end

  describe "#arrives_at=" do
    it "sets arrives_at after adding visit start_time to it as default" do
      form = UserVisitForm.new(params: { id: create(:user_visit).id })
      visit_start_time = Time.current
      arrives_at = Date.current
      form.arrives_at = arrives_at

      expect(form.arrives_at.to_s).to eq("#{arrives_at}#{visit_start_time.to_s[10..]}")
    end

    it "sets arrives_at nil when nil date is set" do
      form = UserVisitForm.new(params: { id: create(:user_visit).id })

      form.arrives_at = nil

      expect(form.arrives_at).to be_nil
    end
  end

  describe "#departs_at=" do
    it "sets departs_at after adding visit end_time to it as default" do
      form = UserVisitForm.new(params: { id: create(:user_visit).id })
      visit_end_time = Time.current
      departs_at = Date.current
      form.departs_at = departs_at

      expect(form.departs_at.to_s).to eq("#{departs_at}#{visit_end_time.to_s[10..]}")
    end

    it "sets departs_at nil when nil date is set" do
      form = UserVisitForm.new(params: { id: create(:user_visit).id })

      form.departs_at = nil

      expect(form.departs_at).to be_nil
    end
  end

  describe "#save" do
    it "saves the user visit if there are no errors" do
      form = UserVisitForm.new(
          params: {
            visit_id: create(:visit).id,
            institution_id: create(:institution).id,
            user_id: create(:user).id,
            arrives_at: Date.current,
            departs_at: Date.current + 2.days,
            role: "Other",
            count: 1,
          },
        )

      result = form.save

      expect(result).to be_truthy
      expect(form.user).to be_persisted
      expect(form.visit).to be_persisted
      expect(form.institution).to be_persisted
    end

    it "makes sure errors are visible when save fails" do
      form = UserVisitForm.new(
          params: {
            visit_id: create(:visit).id,
            institution_id: create(:institution).id,
            user_id: create(:user).id,
            arrives_at: Date.current,
            departs_at: Date.current + 10.days,
            role: "Other",
          },
        )

      result = form.save

      expect(result).to be_falsy
      expect(form.user_visit).to_not be_persisted
      expect(form.errors).to be_present
    end
  end
end
