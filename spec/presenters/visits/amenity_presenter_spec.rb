require "rails_helper"

RSpec.describe Visits::AmenityPresenter do
  describe "delegations to amenity" do
    subject { Visits::AmenityPresenter.new(build(:amenity)) }
    it { is_expected.to delegate_method(:group_number).to(:amenity) }
    it { is_expected.to delegate_method(:description).to(:amenity) }
    it { is_expected.to delegate_method(:reserve).to(:amenity) }
    it { is_expected.to delegate_method(:comment).to(:amenity) }
    it { is_expected.to delegate_method(:unit).to(:amenity).as(:units_type) }
    it { is_expected.to delegate_method(:period).to(:amenity).as(:time_type) }
  end

  describe "delegations to form" do
    subject { Visits::AmenityPresenter.new(nil, form: Visits::AmenityForm.new) }
    it { is_expected.to delegate_method(:arrives_on).to(:form) }
    it { is_expected.to delegate_method(:departs_on).to(:form) }
    it { is_expected.to delegate_method(:number_of_people).to(:form) }
    it { is_expected.to delegate_method(:checked).to(:form) }
  end

  describe "#rates" do
    it "presents its visible, applicable rates in order" do
      insitiution = create(:institution, institution_type: :k_12_education )
      user = create(:user, institution: insitiution)
      amenity = Visits::AmenityPresenter.new(create(:amenity), user: user)
      rates = [
        create(
          :amenity_rate,
          amenity: amenity.amenity,
          sort_order: 1,
          visible: true,
          k12: true,
        ),
        create(
          :amenity_rate,
          amenity: amenity.amenity,
          sort_order: 4,
          visible: true,
          business: true,
        ),
        create(
          :amenity_rate,
          amenity: amenity.amenity,
          sort_order: 2,
          visible: false,
          k12: true
        ),
        create(
          :amenity_rate,
          amenity: amenity.amenity,
          sort_order: 3,
          visible: true,
          k12: true,
        ),
      ]

      presented_rates = amenity.rates

      expect(presented_rates.map(&:id))
        .to eq [rates[0].id, rates[3].id, rates[1].id]
    end
  end

  describe "#rate_descriptions" do
    it "generates the right descriptions for time-period-based rates" do
      amenity = create(:amenity, units_type: :use, time_type: :four_hours)
      create(:amenity_rate, amenity: amenity, rate: "12.34")
      create(:amenity_rate, amenity: amenity, rate: "0.01")
      presenter = Visits::AmenityPresenter.new(amenity)

      rate_descriptions = presenter.rate_descriptions

      expect(rate_descriptions).to eq [
        "$12.34 per use/per 4 hours",
        "$0.01 per use/per 4 hours",
      ]
    end

    it "generates the right descriptions for individual rates" do
      amenity = create(:amenity, units_type: :use, time_type: :each)
      create(:amenity_rate, amenity: amenity, rate: "12.34")
      create(:amenity_rate, amenity: amenity, rate: "0.01")
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

  describe "#image" do
    it "is 'amenity_placeholder.jpg' when image_url is not set" do
      amenity = create(:amenity)
      presenter = Visits::AmenityPresenter.new(amenity)
      
      expect(presenter.image).to eq "amenity_placeholder.jpg"
    end

    it "is equal to image_url when it is set" do
      amenity = create(:amenity, image_url: "https://apod.nasa.gov/apod/image/2202/AuroraPillars_Correia_960.jpg")
      presenter = Visits::AmenityPresenter.new(amenity)
      
      expect(presenter.image).to eq "https://apod.nasa.gov/apod/image/2202/AuroraPillars_Correia_960.jpg"
    end
  end

  describe "#selected_amenity_rate_id" do
    it "returns the default amenity_rate for the user by default" do
      user = create(:user, institution: build(
        :institution, institution_type: :k_12_education
      ))
      amenity = create(:amenity, amenity_rates: [
        create(:amenity_rate, k12: false),
        create(:amenity_rate, k12: true),
      ])
      presenter = Visits::AmenityPresenter.new(amenity, user: user)
      expected_rate = amenity.amenity_rates[1]

      selected_amenity_rate_id = presenter.selected_amenity_rate_id

      expect(selected_amenity_rate_id).to eq expected_rate.id
    end

    it "returns the amenity_rate_id from form (if exists) regardless of user" do
      user = create(:user, institution: build(
        :institution, institution_type: :k_12_education
      ))
      amenity = create(:amenity, amenity_rates: [
        create(:amenity_rate, k12: false),
        create(:amenity_rate, k12: true),
      ])
      selected_rate = amenity.amenity_rates[1]
      expected_rate = amenity.amenity_rates[1]
      form = [Visits::AmenityForm.new(params: { amenity_rate_id: selected_rate.id })]
      presenter = Visits::AmenityPresenter.new(amenity, user: user, form: form)

      selected_amenity_rate_id = presenter.selected_amenity_rate_id

      expect(selected_amenity_rate_id).to eq expected_rate.id
    end
  end

  describe "#default_date" do
    it "should return current date formatted correctly" do
      amenity = create(:amenity, units_type: :use, time_type: :four_hours)
      presenter = Visits::AmenityPresenter.new(amenity)
      travel_to Time.zone.local(2004, 11, 24)

      expect(presenter.default_date(nil)).to eq("")
    end
  end

  describe "#period" do
    it "should return amenity time type" do
      amenity = create(:amenity)
      presenter = Visits::AmenityPresenter.new(amenity)
      expect(presenter.period).to eq(Amenity.time_types[amenity.time_type])
    end
  end
    
  describe "#unit" do
    it "should return amenity unit type" do
      amenity = create(:amenity)
      presenter = Visits::AmenityPresenter.new(amenity)
      expect(presenter.unit).to eq(Amenity.units_types[amenity.units_type])
    end
  end

  describe "#default_count" do
    COUNT = 10
    it "should return given count when count is present" do
      amenity = create(:amenity)
      presenter = Visits::AmenityPresenter.new(amenity)
      expect(presenter.default_count(COUNT)).to eq(COUNT)
    end

    it "should return 1 when count is not present" do
      amenity = create(:amenity)
      presenter = Visits::AmenityPresenter.new(amenity)
      expect(presenter.default_count(nil)).to eq("1")
    end
  end

  describe "#per_sentence" do
    it "should return 'per {unit}' when time type is 'each'" do
      amenity = create(:amenity, time_type: :each)
      presenter = Visits::AmenityPresenter.new(amenity)
      expect(presenter.per_sentence).to eq("per #{presenter.unit}")
    end

    it "should return 'per {unit}/per {period}' when time type is not 'each'" do
      amenity = create(:amenity)
      presenter = Visits::AmenityPresenter.new(amenity)
      expect(presenter.per_sentence).to eq("per #{presenter.unit}/per #{presenter.period}")
    end
  end

  describe "#per" do
    it "should return 'per'" do
      amenity = create(:amenity)
      presenter = Visits::AmenityPresenter.new(amenity)
      
      expect(presenter.per).to eq("per")
    end
  end

  describe "#selected_rate_in_number" do
    it "should return rate in number" do
      insitiution = create(:institution, institution_type: :k_12_education )
      user = create(:user, institution: insitiution)
      presenter = Visits::AmenityPresenter.new(create(:amenity), user: user)
      rates = [
        create(
          :amenity_rate,
          amenity: presenter.amenity,
          sort_order: 1,
          visible: true,
          k12: true,
        ),
        create(
          :amenity_rate,
          amenity: presenter.amenity,
          sort_order: 4,
          visible: true,
          business: true,
        ),
        create(
          :amenity_rate,
          amenity: presenter.amenity,
          sort_order: 2,
          visible: false,
          k12: true
        ),
        create(
          :amenity_rate,
          amenity: presenter.amenity,
          sort_order: 3,
          visible: true,
          k12: true,
        ),
      ]
      rate = presenter.rates.find { |rate| rate.id == presenter.selected_amenity_rate_id }
      expect(presenter.selected_rate_in_number).to eq("#{rate.amount}".delete!("$"))
    end
  end

  describe "#selected_rate_description" do
    it "should return rate with description" do
      insitiution = create(:institution, institution_type: :k_12_education )
      user = create(:user, institution: insitiution)
      presenter = Visits::AmenityPresenter.new(create(:amenity), user: user)
      rates = [
        create(
          :amenity_rate,
          amenity: presenter.amenity,
          sort_order: 1,
          visible: true,
          k12: true,
        ),
        create(
          :amenity_rate,
          amenity: presenter.amenity,
          sort_order: 4,
          visible: true,
          business: true,
        ),
        create(
          :amenity_rate,
          amenity: presenter.amenity,
          sort_order: 2,
          visible: false,
          k12: true
        ),
        create(
          :amenity_rate,
          amenity: presenter.amenity,
          sort_order: 3,
          visible: true,
          k12: true,
        ),
      ]
      rate = presenter.rates.find { |rate| rate.id == presenter.selected_amenity_rate_id }
      expect(presenter.selected_rate_description).to eq("#{rate.amount} #{presenter.per_sentence}")
    end
  end
  
  describe "#amenity_rate_options" do
    it "should return array pair of rate_string and rate id for select options" do
      user = create(:user, institution: build(
        :institution, institution_type: :k_12_education
      ))

      amenity = create(:amenity, amenity_rates: [
        create(:amenity_rate, k12: false),
        create(:amenity_rate, k12: true),
      ])

      presenter = Visits::AmenityPresenter.new(amenity)

      expected_result = presenter.rates.map do |rate|
        rate_string = "#{rate.amount} per #{presenter.unit}"
        if presenter.period != "each"
          rate_string << "/per #{presenter.period}"
        end
        [rate_string, rate.id]
      end

      expect(presenter.amenity_rate_options).to eq expected_result
    end
  end
end
