require "rails_helper"

RSpec.describe "manager superbar", type: :view do
  before do
    without_partial_double_verification do
      allow(view).to receive(:super_admin?).and_return(false)
    end
  end

  context "when in manager namespace" do
    it "display the manager superbar with reserves dropdown" do
      user = create(:user)
      reserve1 = create(:reserve, name: "Desert Reserve")
      reserve2 = create(:reserve, name: "Mountain Reserve")
      create(:reserve_personnel, reserve: reserve1, user: user)
      create(:reserve_personnel, reserve: reserve2, user: user)
      layout_presenter = LayoutPresenter.new(
        current_user: user,
        current_reserve: reserve1,
        controller_path: "manager/",
        dashboard: nil
      )

      render partial: "layouts/manager_superbar", locals: { layout_presenter: layout_presenter }

      expect(rendered).to have_link(reserve1.name, href: "/manager/reserves/#{reserve1.id}/dashboard")
      expect(rendered).to have_link(reserve2.name, href: "/manager/reserves/#{reserve2.id}/dashboard")
    end
  end

  context "when not in manager namespace" do
    it "display the manager superbar without reserves dropdown" do
      user = create(:user)
      reserve1 = create(:reserve, name: "Desert Reserve")
      reserve2 = create(:reserve, name: "Mountain Reserve")
      create(:reserve_personnel, reserve: reserve1, user: user)
      create(:reserve_personnel, reserve: reserve2, user: user)
      layout_presenter = LayoutPresenter.new(
        current_user: user,
        current_reserve: reserve1,
        controller_path: "",
        dashboard: nil
      )

      render partial: "layouts/manager_superbar", locals: { layout_presenter: layout_presenter }

      expect(rendered).not_to have_link(reserve1.name, href: "/manager/reserves/#{reserve1.id}/dashboard")
      expect(rendered).not_to have_link(reserve2.name, href: "/manager/reserves/#{reserve2.id}/dashboard")
    end
  end
end
