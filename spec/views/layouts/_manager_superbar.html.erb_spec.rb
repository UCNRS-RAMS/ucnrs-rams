require "rails_helper"

RSpec.describe "manager superbar", type: :view do
  it "display the manager superbar" do
    user = create(:user)
    reserve1 = create(:reserve, name: "Desert Reserve")
    reserve2 = create(:reserve, name: "Mountain Reserve")
    create(:reserve_personnel, reserve: reserve1, user: user)
    create(:reserve_personnel, reserve: reserve2, user: user)

    render partial: "layouts/manager_superbar", locals: { current_user: user, current_reserve: reserve1 }

    expect(rendered).to have_link("", href: "/users/sign_out")
    expect(rendered).to have_link(reserve1.name, href: "/manager/reserves/#{reserve1.id}/dashboard")
    expect(rendered).to have_link(reserve2.name, href: "/manager/reserves/#{reserve2.id}/dashboard")
  end
end
