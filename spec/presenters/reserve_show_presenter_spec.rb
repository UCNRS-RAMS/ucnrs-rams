require "rails_helper"

RSpec.describe ReserveShowPresenter do
  describe "delegations" do
    subject { ReserveShowPresenter.new(reserve: build(:reserve)) }
    it { is_expected.to delegate_method(:id).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_1).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_2).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_3).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_postal_code).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:state).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:country).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:logo_url).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:logo_placeholder).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:managing_campus).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:description).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:large_hero_photo_url).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:large_hero_photo_placeholder).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:listing_photo_placeholder).to(:reserve).with_prefix(true) }
  end

  describe "#reserve" do
    it "presents reserve informations correctly through the presenter" do
      reserve_one = create(:reserve, id: 1, name: "reserve 1")

      show_presenter = ReserveShowPresenter.new(reserve: reserve_one)

      expect(show_presenter.reserve_id).to eq 1
      expect(show_presenter.reserve_name).to eq "reserve 1"
    end
  end

  describe "#tab_class" do
    it "return 'active' if tab is equals to selected_tab" do
      reserve = create(:reserve)

      show_presenter = ReserveShowPresenter.new(reserve: reserve, selected_tab: "calendar")

      expect(show_presenter.tab_class("calendar")).to eq "active"
    end

    it "return empty string if tab is equals to selected_tab" do
      reserve = create(:reserve)

      show_presenter = ReserveShowPresenter.new(reserve: reserve, selected_tab: "calendar")

      expect(show_presenter.tab_class("more_information")).to eq ""
    end
  end

  describe "#tab_content_path" do
    it "return 'reserve_more_information_index_path' if selected_tab is more_information" do
      reserve = create(:reserve)
      show_presenter = ReserveShowPresenter.new(reserve: reserve, selected_tab: "more_information")
      output = "/reserves/#{reserve.id}/more_information"

      expect(show_presenter.tab_content_path).to eq output
    end

    it "return 'reserve_calendar_path' if selected_tab is calendar" do
      reserve = create(:reserve)
      output = "/reserves/#{reserve.id}/calendar?partial_name=calendar&start_date=#{Date.today}"

      show_presenter = ReserveShowPresenter.new(reserve: reserve, selected_tab: "calendar")

      expect(show_presenter.tab_content_path).to eq output
    end

    it "return 'reserve_waivers_path' if selected_tab is waivers" do
      reserve = create(:reserve)
      output = "/reserves/#{reserve.id}/waivers"

      show_presenter = ReserveShowPresenter.new(reserve: reserve, selected_tab: "waivers")

      expect(show_presenter.tab_content_path).to eq output
    end

    it "return reserve_rules_and_directions_path if selected_tab is rules_and_directions" do
      reserve = create(:reserve)
      output = "/reserves/#{reserve.id}/rules_and_directions"

      show_presenter = ReserveShowPresenter.new(reserve: reserve, selected_tab: "rules_and_directions")

      expect(show_presenter.tab_content_path).to eq output
    end

    it "return reserve_amenities_path if selected_tab is not present" do
      reserve = create(:reserve)
      output = "/reserves/#{reserve.id}/amenities"

      show_presenter = ReserveShowPresenter.new(reserve: reserve)

      expect(show_presenter.tab_content_path).to eq output
    end
  end

  describe "#personnel" do
    it "presents personnel informations correctly through the presenter" do
      reserve = create(:reserve)
      personnel_one = create(:reserve_personnel, id: 1, email: "t.kirk@enterprise.uss", reserve: reserve)
      personnel_two = create(:reserve_personnel, id: 2, email: "spock@enterprise.uss", reserve: reserve)
      personnel_three = create(:reserve_personnel, id: 3, email: "McCoy@enterprise.uss", reserve: reserve)

      show_presenter = ReserveShowPresenter.new(reserve: reserve)

      expect(show_presenter.reserve_personnel.first).to have_attributes(id: 1, email: "t.kirk@enterprise.uss")
      expect(show_presenter.reserve_personnel.second).to have_attributes(id: 2, email: "spock@enterprise.uss")
      expect(show_presenter.reserve_personnel.third).to have_attributes(id: 3, email: "McCoy@enterprise.uss")
    end
  end

  describe "#reserve_alert_message" do
    context "when reserve alert_message is present" do
      it "returns reserve_alert_message correctly by calling simple_format through the presenter" do
        reserve = create(:reserve, reserve_alert_message: "achtung!")
        show_presenter = ReserveShowPresenter.new(reserve: reserve)

        reserve_alert_message = show_presenter.reserve_alert_message

        expect(reserve_alert_message).to eq "<p>achtung!</p>"
      end
    end

    context "when reserve alert_message is NOT present" do
      it "returns nil and not call simple_format through the presenter" do
        reserve = create(:reserve, reserve_alert_message: "")
        show_presenter = ReserveShowPresenter.new(reserve: reserve)

        reserve_alert_message = show_presenter.reserve_alert_message

        expect(reserve_alert_message).to eq nil
      end
    end
  end

  describe "#reserve_description" do
    context "when reserve description is present" do
      it "presents description correctly by calling simple_format through the presenter" do
        reserve = create(:reserve, description: "achtung!")
        show_presenter = ReserveShowPresenter.new(reserve: reserve)

        reserve_description = show_presenter.reserve_description

        expect(reserve_description).to eq "<p>achtung!</p>"
      end
    end

    context "when reserve description is NOT present" do
      it "returns nil and not call simple_format through the presenter" do
        reserve = create(:reserve, description: "")
        show_presenter = ReserveShowPresenter.new(reserve: reserve)

        reserve_description = show_presenter.reserve_description

        expect(reserve_description).to eq nil
      end
    end
  end

  describe "#large_hero_photo_src" do
    context "when a large hero photo is uploaded" do
      it "is the large hero photo's url" do
        reserve = create(:reserve, :with_hero_photo)
        presenter = ReserveShowPresenter.new(reserve: reserve)

        expect(presenter.large_hero_photo_src).to match(/\/test-image.jpeg/)
      end
    end

    context "when there is no uploaded large hero photo" do
      it "is the path of the large hero photo placeholder" do
        reserve = build(:reserve)
        presenter = ReserveShowPresenter.new(reserve: reserve)

        expect(presenter.large_hero_photo_src).to eq(ActionController::Base.helpers.image_path "reserve-hero-placeholder.jpg")
      end
    end
  end

  describe "#logo_src" do
    context "when a reserve logo is uploaded" do
      it "is the reserve logo's url" do
        reserve = create(:reserve, :with_logo)
        presenter = ReserveShowPresenter.new(reserve: reserve)

        expect(presenter.logo_src).to match(/medium_test-image.jpeg/)
      end
    end

    context "when there is no uploaded reserve logo" do
      it "is the path of the reserve logo placeholder" do
        reserve = build(:reserve)
        presenter = ReserveShowPresenter.new(reserve: reserve)

        expect(presenter.logo_src).to eq("reserve_logo_placeholder.png")
      end
    end
  end
end
