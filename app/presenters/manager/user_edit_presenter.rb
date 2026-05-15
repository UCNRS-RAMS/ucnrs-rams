class Manager::UserEditPresenter < RegistrationFormPresenter
  

  def change_password
    link_to I18n.t(".password.change_password"), password_index_path(user_id: form_user.id), method: :post
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
