require "rails_helper"

RSpec.describe Visits::AmenityPresenter do
  describe "delegations to amenity" do
    subject { Visits::AmenityPresenter.new(build(:amenity)) }
    it { is_expected.to delegate_method(:group_number).to(:amenity) }
    it { is_expected.to delegate_method(:description).to(:amenity) }
    it { is_expected.to delegate_method(:image_url).to(:amenity) }
    it { is_expected.to delegate_method(:reserve).to(:amenity) }
    it { is_expected.to delegate_method(:comment).to(:amenity) }
    it { is_expected.to delegate_method(:unit).to(:amenity).as(:units_type) }
    it { is_expected.to delegate_method(:period).to(:amenity).as(:time_type) }
  end

  describe "delegations to form" do
    subject { Visits::AmenityPresenter.new(nil, form: AmenityForm.new) }
    it { is_expected.to delegate_method(:arrives_on).to(:form) }
    it { is_expected.to delegate_method(:departs_on).to(:form) }
    it { is_expected.to delegate_method(:number_of_people).to(:form) }
    it { is_expected.to delegate_method(:checked).to(:form) }
  end

  describe "#rates" do
    it "presents its rates in order" do
      amenity = Visits::AmenityPresenter.new(create(:amenity))
      rates = [
        create(:amenity_rate, amenity: amenity.amenity, sort_order: 1),
        create(:amenity_rate, amenity: amenity.amenity, sort_order: 3),
        create(:amenity_rate, amenity: amenity.amenity, sort_order: 2),
      ]

      presented_rates = amenity.rates

      expect(presented_rates.map(&:id))
        .to eq [rates[0].id, rates[2].id, rates[1].id]
    end
  end

  describe "#rate_descriptions" do
    it "generates the right descriptions for time-period-based rates" do
      amenity = create(:amenity, units_type: :use, time_type: :four_hours)
      rate = create(:amenity_rate, amenity: amenity, rate: "12.34")
      rate = create(:amenity_rate, amenity: amenity, rate: "0.01")
      presenter = Visits::AmenityPresenter.new(amenity)

      rate_descriptions = presenter.rate_descriptions

      expect(rate_descriptions).to eq [
        "$12.34 per use/per four_hours",
        "$0.01 per use/per four_hours",
      ]
    end

    it "generates the right descriptions for individual rates" do
      amenity = create(:amenity, units_type: :use, time_type: :each)
      rate = create(:amenity_rate, amenity: amenity, rate: "12.34")
      rate = create(:amenity_rate, amenity: amenity, rate: "0.01")
      presenter = Visits::AmenityPresenter.new(amenity)

      rate_descriptions = presenter.rate_descriptions

      expect(rate_descriptions).to eq [
        "$12.34 per use",
        "$0.01 per use",
      ]
    end
  end

  describe "#time_options" do
    it "gives options for each half hour" do
      presenter = Visits::AmenityPresenter.new(build(:amenity))

      options = presenter.time_options

      expect(options.map(&:value)).to eq [
        "00:00",
        "01:00",
        "02:00",
        "03:00",
        "04:00",
        "05:00",
        "06:00",
        "07:00",
        "08:00",
        "09:00",
        "10:00",
        "11:00",
        "12:00",
        "13:00",
        "14:00",
        "15:00",
        "16:00",
        "17:00",
        "18:00",
        "19:00",
        "20:00",
        "21:00",
        "22:00",
        "23:00",
      ]
      expect(options.map(&:human)).to eq [
        "12:00 AM",
        "1:00 AM",
        "2:00 AM",
        "3:00 AM",
        "4:00 AM",
        "5:00 AM",
        "6:00 AM",
        "7:00 AM",
        "8:00 AM",
        "9:00 AM",
        "10:00 AM",
        "11:00 AM",
        "12:00 PM",
        "1:00 PM",
        "2:00 PM",
        "3:00 PM",
        "4:00 PM",
        "5:00 PM",
        "6:00 PM",
        "7:00 PM",
        "8:00 PM",
        "9:00 PM",
        "10:00 PM",
        "11:00 PM",
      ]
    end
  end

  describe "#group_label" do
    it "is the label that corresponds to the amenity's group_number" do
      reserve = create(:reserve, amenity_group_label_1: "Housing & Lodging")
      amenity = create(:amenity, group_number: 1, reserve: reserve)
      presenter = Visits::AmenityPresenter.new(amenity)

      expect(presenter.group_label).to eq "Housing & Lodging"
    end

    it "returns the default value for the amenity_group_label if the group number doesn't match" do
      reserve = create(:reserve, amenity_group_label_1: "Housing & Lodging")
      amenity = create(:amenity, group_number: 2, reserve: reserve)
      presenter = Visits::AmenityPresenter.new(amenity)

      expect(presenter.group_label).to eq "2"
    end
  end
end
