require "rails_helper"

RSpec.describe Visits::ReserveInputsPresenter do
  describe "delegation" do
    it "delegates to the reserve if the method is not defined" do
      reserve = build(:reserve, name: "Open Table")
      presenter = Visits::ReserveInputsPresenter.new(reserve)

      expect(presenter.name).to eq "Open Table"
      expect(presenter.pulldown_name).to eq "Open Table"
    end
  end
  
  describe "#alert_message" do
    it "returns the alert_message if it is enabled" do
      reserve = build(
        :reserve,
        reserve_alert_message_enabled: true,
        reserve_alert_message: "Yes!"
      )
      presenter = Visits::ReserveInputsPresenter.new(reserve)

      expect(presenter.alert_message).to eq "Yes!"
    end

    it "returns nil if it is not enabled" do
      reserve = build(
        :reserve,
        reserve_alert_message_enabled: false,
        reserve_alert_message: "No!"
      )
      presenter = Visits::ReserveInputsPresenter.new(reserve)

      expect(presenter.alert_message).to be_nil
    end
  end

  describe "#alert_message_class" do
    it "returns 'reserve-message' if it is enabled" do
      reserve = build(
        :reserve,
        reserve_alert_message_enabled: true,
        reserve_alert_message: "Yes!"
      )
      presenter = Visits::ReserveInputsPresenter.new(reserve)

      expect(presenter.alert_message_class).to eq "reserve-message"
    end

    it "returns nil if it is not enabled" do
      reserve = build(
        :reserve,
        reserve_alert_message_enabled: false,
        reserve_alert_message: "No!"
      )
      presenter = Visits::ReserveInputsPresenter.new(reserve)

      expect(presenter.alert_message_class).to be_nil
    end
  end
end
