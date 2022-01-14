require "rails_helper"

RSpec.describe Reserve, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:managing_campus).class_name("Institution").optional(true) }
    it { is_expected.to have_many(:amenities) }
    it { is_expected.to belong_to(:address_state) }
    it { is_expected.to have_many(:personnel).class_name("ReservePersonnel") }
    it { is_expected.to have_and_belong_to_many(:waivers) }
    it { is_expected.to have_many(:fundings) }
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
