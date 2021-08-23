require "rails_helper"

RSpec.describe Unauthenticated::CreateAccountPageComponent, type: :component do
  it "renders the CreateAccountPageComponent with a title and description" do
    component = Unauthenticated::CreateAccountPageComponent.new(
      title: "Component Title",
      description: "Component Description",
    )

    render_inline(component)

    expect(rendered_component).to have_css("h1", text: "Component Title")
    expect(rendered_component).to have_css("p", text: "Component Description")
  end

  it "renders a CreateAccountFormComponent within the CreateAccountPageComponent" do
    component = Unauthenticated::CreateAccountPageComponent.new(
      title: "Component Title",
      description: "Component Description",
      user: :fake_user,
    )

    render_inline(component) { |c| c.form(user: c.user) }

    expect(rendered_component).to have_css("form")
  end
end
