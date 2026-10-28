require "rails_helper"

RSpec.describe Unauthenticated::RegistrationsController, type: :request do
  let(:country) { create(:country, name: "United States") }
  let(:state) { create(:state, name: "California", country: country) }
  let!(:institution) do
    create(:institution, name: "University of California", country: country, state: state)
  end

  def registration_params
    {
      first_name: "John",
      last_name: "Muir",
      role: "docent",
      phone_number: "(111) 111-1111",
      email: "john@muirwoods.test",
      password: "Password1",
      password_confirmation: "Password1",
      emergency_contact_full_name: "Louisa Wanda Strentzel",
      emergency_contact_phone_number: "(222) 222-2222",
      institution: institution.name,
      address_line_1: "1 Muir Woods Road",
      address_city: "Mill Valley",
      address_country_id: country.id,
      address_state_id: state.id,
      address_postal_code: "94941",
      billing_address_same_as_current: "1",
      terms_accepted_at: "1"
    }
  end

  describe "GET /users/sign_up" do
    it "renders the sign up form" do
      get "/users/sign_up"

      expect(response).to be_ok

      doc = Capybara.string(response.body)
      expect(doc).to have_css("body.registrations.registrations-new")
      expect(doc).to have_field("user_first_name")
      expect(doc).to have_field("user_email")
      expect(doc).to have_field("user_password")
      expect(doc).to have_field("user_institution")
      expect(doc).to have_css("form[action='/users']")
    end
  end

  describe "POST /users" do
    it "creates an unconfirmed user and sends confirmation instructions" do
      expect do
        post "/users", params: { user: registration_params }
      end.to change(User, :count).by(1)

      user = User.find_by!(email: "john@muirwoods.test")
      expect(user).to be_persisted
      expect(user.confirmed?).to be(false)
      expect(user.institution).to eq(institution)
      expect(user.billing_address_city).to eq("Mill Valley")
      expect(ActionMailer::Base.deliveries.last).to be_present
      expect(ActionMailer::Base.deliveries.last.to).to eq([ "john@muirwoods.test" ])

      expect(response).to redirect_to(root_path)
      expect(flash[:success]).to be_present
    end

    it "re-renders the form with an error when the email is already taken" do
      create(:user, :confirmed, email: "john@muirwoods.test")

      expect do
        post "/users", params: { user: registration_params }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)

      doc = Capybara.string(response.body)
      expect(doc).to have_css("body.registrations.registrations-create")
      expect(doc).to have_field("user_first_name", with: "John")
      expect(doc).to have_css(".error_messages", text: "already been taken")
    end

    it "re-renders the form with field errors when required values are missing" do
      post "/users", params: {
        user: registration_params.merge(
          first_name: "",
          last_name: "",
          email: "",
          password: "foo",
          password_confirmation: "foo",
          emergency_contact_full_name: "",
          emergency_contact_phone_number: "",
          address_line_1: "",
          address_city: "",
          address_postal_code: "",
          institution: ""
        )
      }

      expect(response).to have_http_status(:unprocessable_content)

      doc = Capybara.string(response.body)
      expect(doc).to have_css("body.registrations.registrations-create")
      expect(doc).to have_css(".error_messages", text: I18n.t("activerecord.errors.messages.blank"))
      expect(doc).to have_css(".error_messages", text: I18n.t("activerecord.errors.models.user.attributes.password.complexity"))
      expect(doc).to have_field("user_address_city", with: "")
    end
  end

  describe "GET /users/edit" do
    it "renders the account form prefilled with the current values" do
      user = create(:user, :confirmed, first_name: "John", last_name: "Muir", institution: institution)
      sign_in(user)

      get "/users/edit"

      expect(response).to be_ok

      doc = Capybara.string(response.body)
      expect(doc).to have_css("body.registrations.registrations-edit")
      expect(doc).to have_field("user_first_name", with: "John")
      expect(doc).to have_field("user_last_name", with: "Muir")
      expect(doc).to have_field("user_email", with: user.email)
      expect(doc).to have_field("user_institution", with: institution.name)
    end

    it "shows an unauthenticated ORCID status when the stored ORCID has not been authenticated" do
      user = create(:user, :confirmed, orcid: "0000-0002-1825-0097", orcid_authenticated: false)
      sign_in(user)

      get "/users/edit"

      doc = Capybara.string(response.body)
      expect(doc).to have_css("p.orcid-unauthenticated")
      expect(doc).to have_css("button.orcid-auth-button")
    end

    it "shows an authenticated ORCID status when the stored ORCID has been authenticated" do
      user = create(:user, :confirmed, orcid: "0000-0002-1825-0097", orcid_authenticated: true)
      sign_in(user)

      get "/users/edit"

      doc = Capybara.string(response.body)
      expect(doc).to have_css("p.orcid-authenticated")
      expect(doc).to have_no_css("p.orcid-unauthenticated")
      expect(doc).to have_no_css("button.orcid-auth-button")
    end
  end

  describe "PATCH /users" do
    it "updates the user" do
      user = create(:user, :confirmed, first_name: "John", last_name: "Muir", institution: institution)
      sign_in(user)

      patch "/users", params: {
        user: registration_params.merge(first_name: "Archibald", address_city: "Berkeley")
      }

      expect(response).to redirect_to(edit_user_registration_path)

      user.reload
      expect(user.first_name).to eq("Archibald")
      expect(user.address_city).to eq("Berkeley")
      expect(flash[:notice]).to be_present
    end

    it "re-renders the form with errors when the update is invalid" do
      user = create(:user, :confirmed, first_name: "John", last_name: "Muir", institution: institution)
      sign_in(user)

      patch "/users", params: {
        user: registration_params.merge(first_name: "", address_city: "")
      }

      expect(response).to have_http_status(:unprocessable_content)

      doc = Capybara.string(response.body)
      expect(doc).to have_css("body.registrations.registrations-update")
      expect(doc).to have_css(".error_messages", text: I18n.t("activerecord.errors.messages.blank"))
      expect(doc).to have_field("user_last_name", with: "Muir")

      user.reload
      expect(user.first_name).to eq("John")
    end
  end
end
