class RegistrationForm
  def self.params_with_pending_orcid(params, pending_orcid_identifier)
    params = params.to_h
    return params if pending_orcid_identifier.blank?

    params.merge(orcid: pending_orcid_identifier, orcid_authenticated: true)
  end

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
    institution_assigned = assign_selected_institution
    return unless user.valid? && institution_assigned

    User.transaction do
      selected_institution.save! unless selected_institution.persisted?
      user.save!
    end
    true
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
    selected_institution&.id
  end

  def assign(params)
    params = params.to_h.with_indifferent_access

    params.each do |key, value|
      if %w[institution institution_id institution_selection_type].include?(key.to_s)
        next
      else
        self.send("#{key}=", value)
      end
    end

    user.institution = selected_institution if selected_institution

    return if params[:orcid].blank?
    return if params.key?(:orcid_authenticated)

    user.orcid_authenticated = false
  end

  def assign_selected_institution
    institution = selected_institution
    if institution
      user.institution = institution
      true
    else
      selection_errors.each { |error| user.errors.add(:institution, error) }
      false
    end
  end

  def selected_institution
    return @selected_institution if defined?(@selected_institution)

    @selected_institution = if params[:institution_selection_type].present?
      @institution_selection = InstitutionSelection.new(
        id: params[:institution_id],
        type: params[:institution_selection_type],
      )
      @institution_selection.resolve
    elsif params[:institution_id].present?
      Institution.find_by(id: params[:institution_id])
    elsif params[:institution].present?
      Institution.find_by(name: params[:institution])
    end
  end

  def selection_errors
    return ["must exist"] unless defined?(@institution_selection)

    @institution_selection.errors.full_messages
  end

end
