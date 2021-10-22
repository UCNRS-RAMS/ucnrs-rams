require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#body_class" do
    it "generates the class names based on controller and action" do
      allow(controller).to receive(:controller_name).and_return("application")
      allow(controller).to receive(:action_name).and_return("action")

      expect(body_class).to eq("application application-action")
    end
  end

  describe "#active_class_for" do
    it "is 'active' if the passed resource matches the controller name" do
      allow(controller).to receive(:controller_name).and_return("application")

      resulting_class = active_class_for("application")

      expect(resulting_class).to eq("active")
    end

    it "is an empty string if the passed resource does not match the controller name" do
      allow(controller).to receive(:controller_name).and_return("application")

      resulting_class = active_class_for("not_application")

      expect(resulting_class).to be_nil
    end
  end
end
