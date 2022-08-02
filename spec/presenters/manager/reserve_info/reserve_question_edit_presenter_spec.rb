require "rails_helper"

RSpec.describe Manager::ReserveInfo::ReserveQuestionEditPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::ReserveQuestionEditPresenter.new(form: :form) }
    it { is_expected.to delegate_method(:reserve_question).to(:form).with_prefix(true) }
  end

  describe "#form" do
    it "presents ReserveQuestionForm through the presenter" do
      reserve_question = create(:reserve_question)
      form = ReserveQuestionForm.new(reserve_question: reserve_question)
      presenter = Manager::ReserveInfo::ReserveQuestionEditPresenter.new(form: form)

      expect(presenter.form).to be_a ReserveQuestionForm
    end
  end

  describe "#question_type_options" do
    it "is an array of question type options" do
      reserve_question = create(:reserve_question)
      form = ReserveQuestionForm.new(reserve_question: reserve_question)
      presenter = Manager::ReserveInfo::ReserveQuestionEditPresenter.new(form: form)

      question_type_options = presenter.question_type_options

      expect(question_type_options.to_a).to match_array [
        ["Text", "text"],
        ["Yes/No", "boolean"],
      ]
    end
  end

  describe "#location_options" do
    it "is an array of location options" do
      reserve_question = create(:reserve_question)
      form = ReserveQuestionForm.new(reserve_question: reserve_question)
      presenter = Manager::ReserveInfo::ReserveQuestionEditPresenter.new(form: form)

      location_options = presenter.location_options

      expect(location_options.to_a).to match_array [
        ["Projects", "project"],
        ["Visits", "visit"],
      ]
    end
  end

  describe "#reserve_question_id" do
    it "returns the id of the edited reserve_question" do
      reserve_question = create(:reserve_question)
      form = ReserveQuestionForm.new(reserve_question: reserve_question)
      presenter = Manager::ReserveInfo::ReserveQuestionEditPresenter.new(form: form)

      reserve_question_id = presenter.reserve_question_id

      expect(reserve_question_id).to eq reserve_question.id
    end
  end
end
