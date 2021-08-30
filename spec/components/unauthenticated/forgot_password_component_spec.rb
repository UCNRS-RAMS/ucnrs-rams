require "rails_helper"

RSpec.describe Unauthenticated::ForgotPasswordComponent, type: :component do
  it 'generates' do
    user = User.new
    comp = Unauthenticated::ForgotPasswordComponent.new(user)

    render_inline(comp)

    expect(rendered_component).to have_content("Forgot your password?")
    expect(rendered_component).to have_css("form[action='/users/password'][method='post']")
  end
end
