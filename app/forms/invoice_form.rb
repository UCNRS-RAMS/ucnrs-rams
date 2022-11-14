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
    @amenity_visits ||= @visit&.amenity_visits&.map(&method(:wrap_amenity_in_presenter))
  end

  attr_reader :amenity_visits, :visit, :amenity_visit_params, :params, :invoice

  def save
    begin
      ActiveRecord::Base.transaction do
        save_amenities!
        invoice.save!
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
    amenity_visits.all?(&:save!)
  end

  def validate_amenity_visit
    amenity_visits.each(&:valid?)
  end

  def wrap_amenity_in_presenter(amenity_visit)
    checked = amenity_visit_params[amenity_visit.id.to_s]&.delete("checked")
    Visits::AmenityForm.new(
      user: amenity_visit.user,
      params: checked == "1" ? amenity_visit_params[amenity_visit.id.to_s] : { amenity_visit_id: amenity_visit.id },
    )
  end
end
