class Invoice < ApplicationRecord
  STATUS_FILTERS = {
    "invoice_recent" => nil,
    "paid" => "paid",
    "balance_due" => "due",
  }.freeze

  has_many :invoice_recipients, dependent: :destroy
  has_many :users, through: :invoice_recipients
  has_many :invoice_payments, dependent: :destroy
  has_many :amenity_visits, dependent: :nullify
  belongs_to :visit
  has_many :invoice_payments

  def self.recent_first
    order(created_at: :desc)
  end

  def self.by_reserve(reserve_id)
    if reserve_id.present?
      includes(:visit).where(visits: { reserve_id: reserve_id })
    else
      all
    end
  end

  def self.for_status(status)
    if status.present?
      where(id: select{|invoice| invoice.status.eql?(status) }.pluck(:id))
    else
      all
    end
  end

  def status
    balance_due > 0 ? "due" : "paid"
  end

  def updated_balance
    self.balance_due = invoice_total - payments_amount_total
    self.save
  end

  def payments_amount_total
    invoice_payments.sum(&:amount)
  end

  def invoice_total
    amenity_visits.sum(&:subtotal)
  end

  def updated_balance
    self.balance_due = invoice_total - payments_amount_total
    self.save!
  end
end
