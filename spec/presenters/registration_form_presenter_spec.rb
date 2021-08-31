require "rails_helper"

RSpec.describe RegistrationFormPresenter do
  describe "#identifier_for" do
    it "generates useful and readable identifiers" do
      f = RegistrationFormPresenter.new

      expect(f.identifier_for("age_range", "15-50")).to eq :age_range_15_50
      expect(f.identifier_for("age_range", "50 or older"))
        .to eq :age_range_50_or_older
      expect(f.identifier_for(
        "role",
        "Research Assistant (non-student/faculty/postdoc)"
      )).to eq :role_research_assistant_non_student_faculty_postdoc
      expect(f.identifier_for("role", "Staff")).to eq :role_staff
    end
  end
end
