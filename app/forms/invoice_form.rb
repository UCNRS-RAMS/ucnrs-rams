# frozen_string_literal: true

class InvoiceForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Invoice)
  end

  def initialize(invoice: nil, params: {})
    @params = params
    @invoice = invoice || Invoice.new
    @visit = Visit.where(id: params[:visit_id]).first
    @amenity_visit_params = params.delete(:amenity_visit) || {}
    @amenity_visits ||= filtered_amenity_visits&.map(&method(:wrap_amenity_in_form))
  end

  delegate :id, to: :invoice, prefix: true, allow_nil: true
  
  attr_reader :amenity_visits, :visit, :amenity_visit_params, :params, :invoice

  def save
    begin
      ActiveRecord::Base.transaction do
        invoice.save!
        save_amenities!
        save_invoice_recipients
        true
      end
    rescue ActiveRecord::RecordInvalid => e
      validate_amenity_visit
      false
    end
  end

  private

  def save_invoice_recipients
    params[:project_team_members].each_value do |invoice_recipient_params|
      invoice.invoice_recipients.create(user_id: invoice_recipient_params[:user_id]) if invoice_recipient_params[:check] == "1"
    end
  end

  def save_amenities!
    amenity_visits.each do |amenity_visit|
      amenity_visit.invoice_id = invoice.id
      amenity_visit.save!
    end
  end

  def validate_amenity_visit
    amenity_visits.each(&:valid?)
  end

  def wrap_amenity_in_form(amenity_visit)
    checked = amenity_visit_params[amenity_visit.id.to_s]&.delete("checked")
    Visits::AmenityForm.new(
      user: amenity_visit.user,
      params: checked == "1" ? amenity_visit_params[amenity_visit.id.to_s] : { amenity_visit_id: amenity_visit.id },
      create_invoice: (checked == "1")
    )
  end

  def filtered_amenity_visits
    visit.amenity_visits.where.not(invoice_id: visit.invoice_ids)
  end
end
