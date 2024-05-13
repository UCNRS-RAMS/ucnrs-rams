require "rails_helper"

RSpec.describe Manager::Visits::LogPresenter do
  describe "#action_name" do
    it "should return the action name for log record based on about" do
      metadata = {
        "action" => "submitted",
        "comment" => "",
        "about_type" => "Application",
        "about_id" => 45075,
        "changes" => {
          "ApplicationStatus" => ["Temp", "Open"],
          "submitted_at" => [nil, "2020-05-23T16:03:56.000-07:00"]
        }
      }
      log1 = create(:log, metadata: metadata.to_json)
      metadata["about_type"] = "test"
      log2 = create(:log, metadata: metadata.to_json)
      presenter1 = Manager::Visits::LogPresenter.new(record: log1)
      presenter2 = Manager::Visits::LogPresenter.new(record: log2)

      expect(presenter1.action_name).to eq("Application submitted")
      expect(presenter2.action_name).to eq("test submitted")
    end
  end

  describe "#date" do
    it "should return the formatted date with time" do
      travel_to Time.zone.local(2004, 11, 24, 1, 4, 44)
      log = create(:log, created_at: Time.current)
      presenter = Manager::Visits::LogPresenter.new(record: log)

      expect(presenter.date).to eq("Nov. 24, 2004 at  1:04 AM")
    end
  end

  describe "#details" do
    it "should return the log details" do
      metadata = {
        "details"=>"test log details",
      }
      log = create(:log, metadata: metadata.to_json)
      presenter = Manager::Visits::LogPresenter.new(record: log)

      expect(presenter.details).to eq("test log details")
    end
  end

  describe "#user_name" do
    it "should return the full name of the user" do
      user = create(:user, first_name: "mr", last_name: "smith")
      log = create(:log, user: user)
      presenter = Manager::Visits::LogPresenter.new(record: log)

      expect(presenter.user_name).to eq(user.full_name)
    end
  end
end
