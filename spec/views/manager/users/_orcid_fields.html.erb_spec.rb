require "rails_helper"

RSpec.describe "manager/users/_orcid_fields.html.erb", type: :view do
  let(:orcid_label) { "ORCID" }
  let(:orcid_link_text) { "What is ORCID?" }
  let(:orcid_url) { "https://orcid.org" }

  it "keeps the ORCID as an editable text field when the value is invalid" do
    user = User.new(orcid: "invalid-orcid", orcid_authenticated: false)
    user.errors.add(:orcid, :invalid)

    FakeForm.fields_for(user) do |f|
      render partial: "manager/users/orcid_fields",
        locals: {
          f: f,
          orcid_label: orcid_label,
          orcid_link_text: orcid_link_text,
          orcid_url: orcid_url,
        }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_field("ORCID", type: "text", with: "invalid-orcid")
    expect(doc).not_to have_css("input[type='hidden'][name='user[orcid]']", visible: false)
    expect(doc).not_to have_css("p.orcid-authenticated")
  end

  it "shows authenticated ORCID as read-only display with hidden field" do
    user = User.new(orcid: "0000-0002-1825-0097", orcid_authenticated: true)

    FakeForm.fields_for(user) do |f|
      render partial: "manager/users/orcid_fields",
        locals: {
          f: f,
          orcid_label: orcid_label,
          orcid_link_text: orcid_link_text,
          orcid_url: orcid_url,
        }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_css("p.orcid-authenticated")
    expect(doc).to have_link("https://orcid.org/0000-0002-1825-0097")
    expect(doc).to have_css("input[type='hidden'][name='user[orcid]'][value='0000-0002-1825-0097']", visible: false)
    expect(doc).not_to have_field("ORCID", type: "text")
  end
end

