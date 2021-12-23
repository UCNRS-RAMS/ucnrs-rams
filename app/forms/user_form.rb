class UserForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(User)
  end

  attr_reader :user

  def initialize(params = {})
    @user = User.new(params)
  end

  delegate :id, to: :user
end
