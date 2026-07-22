class RegistrationForm
  def initialize(user: User.new, params: {})
    @user = user
    @params = params
    assign(params)

    if billing_address_same_as_current_address?
      copy_address_fields_to_billing_address
    end

    if terms_accepted?
      user.assign_attributes(terms_accepted_at: Time.current)
    end
  end

  attr_reader :user

  delegate :errors, to: :user
  delegate_missing_to :user

  def terms_accepted?
    ActiveModel::Type::Boolean.new.cast(params[:terms_accepted_at])
  end

  def submit
    user.valid?
    return false if user.errors.any?
    user.save
  end

  private

  attr_reader :params

  def copy_address_fields_to_billing_address
    user.assign_attributes(
      billing_address_line_1: params[:address_line_1],
      billing_address_line_2: params[:address_line_2],
      billing_address_city: params[:address_city],
      billing_address_postal_code: params[:address_postal_code],
      billing_address_state_id: params[:address_state_id],
      billing_address_country_id: params[:address_country_id],
    )
  end

  def billing_address_same_as_current_address?
    ActiveModel::Type::Boolean.new.cast(params[:billing_address_same_as_current])
  end

  def institution_id
    Institution.find_by(name: params[:institution])&.id
  end

  def assign(params)
    if orcid_value_submitted?(params) && !orcid_authenticated_value_submitted?(params)
      user.orcid_authenticated = false
    end

    params.each do |key, value|
      if key.to_s == "institution"
        self.institution_id = institution_id
      else
        self.send("#{key}=", value)
      end
    end
  end

  def orcid_value_submitted?(params)
    params.key?(:orcid) || params.key?("orcid")
  end

  def orcid_authenticated_value_submitted?(params)
    params.key?(:orcid_authenticated) || params.key?("orcid_authenticated")
  end

end
