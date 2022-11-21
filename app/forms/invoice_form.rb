# frozen_string_literal: true

class InvoiceForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Invoice)
  end

  def initialize(invoice: nil, params: {}, editing: false)
    @editing = editing
    @params = params
    @visit = Visit.where(id: params[:visit_id]).first
    @invoice = invoice || @visit.invoices.new
    @amenity_visit_params = params.delete(:amenity_visit) || {}
    @amenity_visits ||= filtered_amenity_visits&.map(&method(:wrap_amenity_in_form))
    assign(invoice_params)
  end

  delegate :id, to: :invoice, prefix: true, allow_nil: true
  delegate_missing_to :invoice

  attr_reader :amenity_visits, :visit, :amenity_visit_params, :params, :invoice, :editing

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

  def modify_number
    editing ? invoice.modify_number.to_i + 1 : invoice.modify_number
  end

  def amenities_total
    "$#{value(amenity_visits.sum(&:subtotal))}"
  end

  def amenity_visit_checked?(is_invoiced)
    editing ? is_invoiced : true
  end

  def is_recipient_checked?(user_id)
    editing ? invoice_recipient(user_id).present? : true
  end

  private

  def assign(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def save_invoice_recipients
    params[:project_team_members].each_value do |invoice_recipient_params|
      recipient = invoice_recipient(invoice_recipient_params[:user_id])
      if recipient_unchecked?(invoice_recipient_params[:check], recipient)
        recipient.destroy
      elsif recipient_checked?(invoice_recipient_params[:check], recipient)
        invoice.invoice_recipients.create(user_id: invoice_recipient_params[:user_id])
      end
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
    if editing
      unchecked_amenity_visits.or(invoice.amenity_visits)
    else
      unchecked_amenity_visits
    end
  end

  def unchecked_amenity_visits
    visit.amenity_visits.where.not(invoice_id: visit.invoice_ids)
  end
  
  def value(num)
    format("%0.2f", num)
  end

  def invoice_recipient(user_id)
    invoice.invoice_recipients.find_by(user_id: user_id)
  end

  def recipient_unchecked?(check, recipient)
    (check == "0" && recipient.present?)
  end

  def recipient_checked?(check, recipient)
    (check == "1" && recipient.blank?)
  end

  def invoice_params
    return {} if params[:invoice].blank?
    params[:invoice]
  end
end
