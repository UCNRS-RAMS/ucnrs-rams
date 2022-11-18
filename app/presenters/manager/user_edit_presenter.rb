class Manager::UserEditPresenter < RegistrationFormPresenter
  def initialize(user)
    super(user)
  end

  delegate :id,
    :full_name,
    :institution,
    to: :form_user,
    prefix: :user

  delegate :name,
    to: :user_institution,
    prefix: true
end
