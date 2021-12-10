class UserPresenter
  def initialize(user)
    @user = user
  end

  delegate_missing_to :user

  def autocomplete_description
    "#{full_name} - #{institution_name} - #{masked_email}"
  end

  def masked_email
    user, host = email.split("@")
    masked_user = "x" * user.length
    masked_user[0] = user[0]
    masked_user[-1] = user[-1]
    [masked_user, host].join("@")
  end

  private

  attr_accessor :user
end
