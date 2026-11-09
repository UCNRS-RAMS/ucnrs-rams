require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#visit_update" do
    it "sends email with visit type information" do
      project = create(:project, project_type: :research)
      user = create(:user, email: "user@example.com", first_name: "John", last_name: "Doe")
      reserve = create(:reserve, short_name: "Test Reserve")
      starts_at = Time.zone.local(2024, 3, 15, 10, 0, 0)
      ends_at = Time.zone.local(2024, 3, 15, 14, 0, 0)
      visit = create(:visit, user: user, project: project, reserve: reserve, starts_at: starts_at, ends_at: ends_at, status: :approved)

      email = UserMailer.with(
        visit: visit,
        approval_message: "Your visit has been approved.",
        email_to_list: [user.email],
        bcc_personnel: false
      ).visit_update

      expect(email.to).to eq [user.email]
      expect(email.subject).to include("Update for Visit")
      expect(email.body.encoded).to include("Research")
      expect(email.body.encoded).to include("Visit Type")
    end

    it "includes visit type for class project" do
      project = create(:project, project_type: :class)
      user = create(:user, email: "user@example.com")
      visit = create(:visit, user: user, project: project)

      email = UserMailer.with(
        visit: visit,
        approval_message: "Your visit has been approved.",
        email_to_list: [user.email],
        bcc_personnel: false
      ).visit_update

      expect(email.body.encoded).to include("Class")
    end

    it "includes visit type for public use project" do
      project = create(:project, project_type: :public_use)
      user = create(:user, email: "user@example.com")
      visit = create(:visit, user: user, project: project)

      email = UserMailer.with(
        visit: visit,
        approval_message: "Your visit has been approved.",
        email_to_list: [user.email],
        bcc_personnel: false
      ).visit_update

      expect(email.body.encoded).to include("Public Use")
    end

    it "includes visit type before arrival and departure information" do
      project = create(:project, project_type: :research)
      user = create(:user, email: "user@example.com")
      starts_at = Time.zone.local(2024, 3, 15, 10, 0, 0)
      ends_at = Time.zone.local(2024, 3, 16, 14, 0, 0)
      visit = create(:visit, user: user, project: project, starts_at: starts_at, ends_at: ends_at)

      email = UserMailer.with(
        visit: visit,
        approval_message: "Your visit has been approved.",
        email_to_list: [user.email],
        bcc_personnel: false
      ).visit_update

      body = email.body.encoded
      visit_type_index = body.index("Visit Type")
      arrival_departure_index = body.index("Arrival and Departure")

      expect(visit_type_index).not_to be_nil
      expect(arrival_departure_index).not_to be_nil
      expect(visit_type_index).to be < arrival_departure_index
    end
  end
end

