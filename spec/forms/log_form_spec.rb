require "rails_helper"

RSpec.describe LogForm, type: :model do
  describe "initializing" do
    it "makes a new LogForm from params" do
      user = create(:user)
      project = create(:project)
      visit = create(:visit)
      params = {
        user_id: user.id,
        action: :created
      }
      form = LogForm.new(params: params, record: visit, record_about: project)

      expect(form).to have_attributes(
        "action" => "created",
        "record_type" => "Visit",
        "record_id"=> visit.id,
        "record_about_id" => project.id,
        "record_about_type" => "Project",
        "user_id" => user.id,
      )
    end
  end

  describe "#save" do
    it "saves Log" do
      user = create(:user)
      project = create(:project)
      visit = create(:visit)
      params = {
        user_id: user.id,
        action: :created
      }
      form = LogForm.new(params: params, record: visit, record_about: project)

      result = form.save
      expect(result).to be_truthy
      expect(form.log).to be_persisted
    end
  end

  describe ".create" do
    it "craete and save Log" do
      user = create(:user)
      project = create(:project)
      visit = create(:visit)
      params = {
        user_id: user.id,
        action: :created
      }
      form = LogForm.create(params: params, record: visit, record_about: project)

      expect(form).to be_truthy
    end
  end
end
