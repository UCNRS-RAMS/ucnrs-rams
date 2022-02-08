require "rails_helper"

RSpec.describe ProjectPermitAnswerPresenter do
  describe "delegations" do
    subject { ProjectPermitAnswerPresenter.new(create(:project_permit_answer)) }
    it { is_expected.to delegate_method(:statement).to(:permit) }
    it { is_expected.to delegate_method(:question).to(:permit) }
    it { is_expected.to delegate_missing_methods_to(:project_permit_answer) }
  end

  describe "#permit_statement" do
    it "displays a statement if the permit has one" do
      permit_with_statment = create(:permit, statement: "Something important and declarative")
      project_permit_answer = build(:project_permit_answer, permit: permit_with_statment)
      presenter = ProjectPermitAnswerPresenter.new(project_permit_answer)

      expect(presenter.permit_statement). to eq "Something important and declarative"
    end

    it "displays a question if the permit does not have a statement" do
      permit_without_statment = create(:permit, question: "Where is the statement?", statement: nil)
      project_permit_answer = build(:project_permit_answer, permit: permit_without_statment)
      presenter = ProjectPermitAnswerPresenter.new(project_permit_answer)

      expect(presenter.permit_statement). to eq "Where is the statement?"
    end
  end
end
