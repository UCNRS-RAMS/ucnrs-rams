require "rails_helper"

RSpec.describe "app/views/projects/fundings/_funding.html.erb", type: :view do
  describe "viewing a funding row" do
    it "has the correct values for the columns" do
      funding = create(
        :funding,
        title: "Ca$h",
        principal_investigators: "Mister Moustache",
        sponsor: :other,
        sponsor_other: "Some Wealthy Foundation",
        award_amount: "1000000",
      )
      presenter = Projects::FundingPresenter.new(funding)

      render partial: "projects/fundings/funding", locals: { funding: presenter }

      doc = Capybara.string(rendered)
      expect(doc).to have_css("td:nth-child(1)", text: "Ca$h")
      expect(doc).to have_css("td:nth-child(2)", text: "Some Wealthy Foundation")
      expect(doc).to have_css("td:nth-child(3)", text: "$1,000,000.00")
    end
  end
end
