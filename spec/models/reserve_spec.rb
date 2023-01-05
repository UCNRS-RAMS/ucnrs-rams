require "rails_helper"

RSpec.describe Reserve, type: :model do
  describe "associations" do
    it { should have_rich_text(:rules_and_regulations) }
    it { should have_one_attached(:reserve_avatar) }

    it { is_expected.to belong_to(:managing_campus).class_name("Institution").optional(true) }
    it { is_expected.to have_many(:amenities) }
    it { is_expected.to belong_to(:address_state).optional(true) }
    it { is_expected.to have_many(:amenity_rate_categories) }
    it { is_expected.to have_many(:personnel).class_name("ReservePersonnel") }
    it { is_expected.to have_and_belong_to_many(:waivers) }
    it { is_expected.to have_many(:fundings) }
    it { is_expected.to have_many(:reserve_questions) }
    it { is_expected.to have_many(:addendums).class_name("ReserveAddendum") }
    it { is_expected.to have_many(:reserve_permits) }
    it { is_expected.to have_many(:permits).through(:reserve_permits) }
    it { is_expected.to have_many(:visits) }
    it { is_expected.to have_many(:reserve_tags).dependent(:destroy) }
  end

  describe "validations" do
    describe "listing_photo" do
      context "when the listing photo is in a valid format" do
        it "is valid" do
          reserve = build(:reserve, :with_listing_photo)

          reserve.save

          expect(reserve).to be_valid
          expect(reserve.listing_photo_url).to be_present
        end
      end

      context "when the listing photo is in an invalid format (non-image)" do
        it "is not valid" do
          reserve = build(:reserve, :with_invalid_file_format)

          reserve.save

          expect(reserve).not_to be_valid
          expect(reserve.errors.full_messages).to include("Listing photo You are not allowed to upload \"pdf\" files, allowed types: jpg, jpeg, gif, png")
        end
      end
    end

    describe "large_hero_photo" do
      context "when the large hero photo is in a valid format" do
        it "is valid" do
          reserve = build(:reserve, :with_hero_photo)

          reserve.save

          expect(reserve).to be_valid
          expect(reserve.large_hero_photo_url).to be_present
        end
      end

      context "when the large hero photo is in an invalid format (non-image)" do
        it "is not valid" do
          reserve = build(:reserve, :with_invalid_file_format)

          reserve.save

          expect(reserve).not_to be_valid
          expect(reserve.errors.full_messages).to include("Large hero photo You are not allowed to upload \"pdf\" files, allowed types: jpg, jpeg, gif, png")
        end
      end
    end
  end

  describe ".with_accepted_project_type" do
    it "returns reserves that accept projects of type 'research'" do
      research_reserve = create(:reserve, research_projects_accepted: true)
      non_research_reserve = create(:reserve, research_projects_accepted: false)

      results = Reserve.with_accepted_project_type("research")

      expect(results).to eq [research_reserve]
    end

    it "returns reserves that accept projects of type 'university_class'" do
      class_reserve = create(:reserve, class_projects_accepted: true)
      non_class_reserve = create(:reserve, class_projects_accepted: false)

      results = Reserve.with_accepted_project_type("university_class")

      expect(results).to eq [class_reserve]
    end

    it "returns reserves that accept projects of type 'meeting_or_conference'" do
      conference_reserve = create(:reserve, conference_projects_accepted: true)
      non_conference_reserve = create(:reserve, conference_projects_accepted: false)

      results = Reserve.with_accepted_project_type("meeting_or_conference")

      expect(results).to eq [conference_reserve]
    end

    it "returns reserves that accept projects of type 'public_use'" do
      public_reserve = create(:reserve, public_projects_accepted: true)
      non_public_reserve = create(:reserve, public_projects_accepted: false)

      results = Reserve.with_accepted_project_type("public_use")

      expect(results).to eq [public_reserve]
    end

    it "returns an empty scope when anything else is passed" do
      expect(Reserve.with_accepted_project_type("foo")).to eq []
    end
  end

  describe ".searching_term" do
    it "returns reserves that have pulldown_name like search filled value" do
      matching_reserve = create(:reserve, pulldown_name: "reserve 1 pulldown_name")
      non_matching_reserve = create(:reserve, pulldown_name: "Hasting")

      results = Reserve.searching_term("pulldown_name")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have directions like search filled value" do
      matching_reserve = create(:reserve, directions: "reserve 1 directions")
      non_matching_reserve = create(:reserve, directions: "Hasting")

      results = Reserve.searching_term("directions")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have department like search filled value" do
      matching_reserve = create(:reserve, department: "reserve 1 department")
      non_matching_reserve = create(:reserve, department: "Hasting")

      results = Reserve.searching_term("department")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have address_line_1 like search filed value" do
      matching_reserve = create(:reserve, address_line_1: "reserve 1 address_line_1")
      non_matching_reserve = create(:reserve, address_line_1: "Hasting")

      results = Reserve.searching_term("address_line_1")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have rules like search filed value" do
      matching_reserve = create(:reserve, rules: "reserve 1 rules")
      non_matching_reserve = create(:reserve, rules: "Hasting")

      results = Reserve.searching_term("rules")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have rates like search filed value" do
      matching_reserve = create(:reserve, rates: "reserve 1 rates")
      non_matching_reserve = create(:reserve, rates: "Hasting")

      results = Reserve.searching_term("rates")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have short_name like search filed value" do
      matching_reserve = create(:reserve, short_name: "reserve 1 short_name")
      non_matching_reserve = create(:reserve, short_name: "Hasting")

      results = Reserve.searching_term("short_name")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have name like search filed value" do
      matching_reserve = create(:reserve, name: "reserve 1 name")
      non_matching_reserve = create(:reserve, name: "Hasting")

      results = Reserve.searching_term("name")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have address_line_2 like search filed value" do
      matching_reserve = create(:reserve, address_line_2: "reserve 1 address_line_2")
      non_matching_reserve = create(:reserve, address_line_2: "Hasting")

      results = Reserve.searching_term("address_line_2")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have address_city like search filed value" do
      matching_reserve = create(:reserve, address_city: "reserve 1 address_city")
      non_matching_reserve = create(:reserve, address_city: "Hasting")

      results = Reserve.searching_term("address_city")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have State like search filed value" do
      state = create(:state, name: "reserve 1 State")
      matching_reserve = create(:reserve, address_state: state)
      non_matching_reserve = create(:reserve, State: "Hasting")

      results = Reserve.searching_term("reserve 1 Stat")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have address_postal_code like search filed value" do
      matching_reserve = create(:reserve, address_postal_code: "reserve 11")
      non_matching_reserve = create(:reserve, address_postal_code: "Hasting")

      results = Reserve.searching_term("reserve 11")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have Country like search filed value" do
      country = create(:country, name: "reserve 1 Country")
      matching_reserve = create(:reserve, address_country: country)
      non_matching_reserve = create(:reserve, Country: "Hasting")

      results = Reserve.searching_term("Country")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have home_page_url like search filed value" do
      matching_reserve = create(:reserve, home_page_url: "reserve 1 home_page_url")
      non_matching_reserve = create(:reserve, home_page_url: "Hasting")

      results = Reserve.searching_term("home_page_url")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have special_needs_statement like search filed value" do
      matching_reserve = create(:reserve, special_needs_statement: "reserve 1 special_needs_statement")
      non_matching_reserve = create(:reserve, special_needs_statement: "Hasting")

      results = Reserve.searching_term("special_needs_statement")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have doi like search filed value" do
      matching_reserve = create(:reserve, doi: "reserve 1 doi")
      non_matching_reserve = create(:reserve, doi: "Hasting")

      results = Reserve.searching_term("doi")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have administrative_group_name like search filed value" do
      matching_reserve = create(:reserve, administrative_group_name: "reserve 1 administrative_group_name")
      non_matching_reserve = create(:reserve, administrative_group_name: "Hasting")

      results = Reserve.searching_term("administrative_group_name")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have administrative_group_name_acronym like search filed value" do
      matching_reserve = create(:reserve, administrative_group_name_acronym: "reserve 1 administrative_group_name_acronym")
      non_matching_reserve = create(:reserve, administrative_group_name_acronym: "Hasting")

      results = Reserve.searching_term("administrative_group_name_acronym")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns reserves that have administrative_group_state like search filed value" do
      matching_reserve = create(:reserve, administrative_group_state: "reserve 1 administrative_group_state")
      non_matching_reserve = create(:reserve, administrative_group_state: "Hasting")

      results = Reserve.searching_term("administrative_group_state")

      expect(results.map(&:id)).to match_array [matching_reserve.id]
    end

    it "returns all reserves if search filed value is empty" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)

      results = Reserve.searching_term("")

      expect(results.map(&:id)).to match_array [reserve1.id, reserve2.id]
    end
  end

  describe "#listing_photo_placeholder" do
    it "is the file name of the listing photo placeholder image" do
      reserve = build(:reserve)

      expect(reserve.listing_photo_placeholder).to eq("reserve_placeholder.jpg")
    end
  end

  describe ".with_tag_type" do
    context "when given tag_types is present" do
      it "returns reserve associated with reserve_tag with the given tag_types" do
        reserve1 = create(:reserve)
        reserve2 = create(:reserve)
        reserve3 = create(:reserve)

        reserve_tag1 = create(:reserve_tag, reserve: reserve1, tag_type: :geographic)
        reserve_tag2 = create(:reserve_tag, reserve: reserve2, tag_type: :ecosystem)
        reserve_tag3 = create(:reserve_tag, reserve: reserve3, tag_type: :geographic)

        results = Reserve.with_tag_type([:geographic])

        expect(results).to eq [reserve1, reserve3]
      end
    end

    context "when given tag_types is not present" do
      it "returns all reserves" do
        reserve1 = create(:reserve)
        reserve2 = create(:reserve)
        reserve3 = create(:reserve)

        reserve_tag1 = create(:reserve_tag, reserve: reserve1, tag_type: :geographic)
        reserve_tag2 = create(:reserve_tag, reserve: reserve2, tag_type: :ecosystem)
        reserve_tag3 = create(:reserve_tag, reserve: reserve3, tag_type: :geographic)

        results = Reserve.with_tag_type(nil)

        expect(results).to eq [reserve1, reserve2, reserve3]
      end
    end
  end

  describe "#large_hero_photo_placeholder" do
    it "is the file name of the large hero photo placeholder image" do
      reserve = build(:reserve)

      expect(reserve.large_hero_photo_placeholder).to eq("reserve-hero-placeholder.jpg")
    end
  end
end
