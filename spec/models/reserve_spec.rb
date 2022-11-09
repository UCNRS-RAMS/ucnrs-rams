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
end
