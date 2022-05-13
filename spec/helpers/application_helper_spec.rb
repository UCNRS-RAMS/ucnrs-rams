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

  describe "#active_link_to_by_url" do
    let(:request) { double('request', path: '/some-path') }

    context "when the path for the link is not the same as the page request path" do
      it "create a link without 'active' in its class" do
        allow(URI).to receive_message_chain(:parse, :path).and_return("/some-different-path")

        resulting_link_to1 = active_link_to_by_url("link_name1", "link1")
        resulting_link_to2 = active_link_to_by_url("link_name2", "link2", class: "class")

        expect(resulting_link_to1).to eq(link_to("link_name1", "link1"))
        expect(resulting_link_to2).to eq(link_to("link_name2", "link2", class: "class"))
      end
    end

    context "when the path for the link is the same as the page request path" do
      it "create a link that contain 'active' when no class is given" do
        allow(URI).to receive_message_chain(:parse, :path).and_return("/some-path")

        resulting_link_to = active_link_to_by_url("link_name", "link")

        expect(resulting_link_to).to eq(link_to("link_name", "link", class:"active"))
      end

      it "create a link that add 'active' when class is given" do
        allow(URI).to receive_message_chain(:parse, :path).and_return("/some-path")

        resulting_link_to = active_link_to_by_url("link_name", "link", class: "test")

        expect(resulting_link_to).to eq(link_to("link_name", "link", class:"test active"))
      end
    end
  end
end
