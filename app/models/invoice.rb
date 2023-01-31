class Invoice < ApplicationRecord
  acts_as_paranoid

  NUMERIC_SEARCH_PATTERN = /\A\d+\z/
  STATUS_FILTERS = {
    "invoice_recent" => nil,
    "paid" => "paid",
    "balance_due" => "due",
  }.freeze

  OPTIONS_FILTERS = {
    "visit_invoices" => "visit_invoices",
    "project_invoices" => "project_invoices"
  }.freeze

  has_many :invoice_recipients, dependent: :destroy
  has_many :users, through: :invoice_recipients
  has_many :invoice_payments, dependent: :destroy
  has_many :amenity_visits, dependent: :nullify
  belongs_to :visit
  has_many :invoice_payments
  has_many :logs, as: :record_about

  def self.recent_first
    order(created_at: :desc)
  end

  def self.by_project(project_id)
    if project_id.present?
      joins(:visit).where(visits: { project_id: project_id })
    else
      all
    end
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

  def self.searching_term(search_filter)
    if search_filter.present? && NUMERIC_SEARCH_PATTERN === search_filter
      where(id: search_filter)
    elsif search_filter.present?
      left_outer_joins(visit: [{ user: :institution }, :project])
        .where(
          Arel.sql(<<-end_sql)
            invoices.notes LIKE "%#{search_filter}%" OR
            projects.title LIKE "%#{search_filter}%" OR
            users.last_name LIKE "%#{search_filter}%" OR
            users.email LIKE "%#{search_filter}%" OR
            institutions.name LIKE "%#{search_filter}%"
          end_sql
        )
        .group(:id)
    else
      all
    end
  end
  
  def self.sort_using(sort_option = nil)
    case sort_option.to_s
    when "created_recent_first" then order(:invoiced_on)
    when "sort_by_amount" then sort_by_amount
    when "sort_by_balance_due" then order(:balance_due)
    when "sort_by_invoice_number" then order(:id)
    else
      all
    end
  end
  
  def self.for_status_filter(status_filter)
    if status_filter == "all"
      all
    elsif STATUS_FILTERS[status_filter] == "due"
       where(Invoice.arel_table[:balance_due].gt(0))
    else
      where(Invoice.arel_table[:balance_due].lteq(0))
    end
  end

  def self.with_invoices_at_reserve(reserve)
    if reserve.present?
      joins(:visit)
        .where(visits: { reserve: reserve })
    else
      all
    end
  end

  def self.having_between_time_for(date_range_option: nil, date_start: nil, date_end: nil)
    case date_range_option
    when :visit_date_range
      having_visit_end_date_after(date_start).having_visit_start_date_before(date_end)
    when :invoiced_on
      having_invoiced_date_after(date_start).having_invoiced_date_before(date_end)
    else
      all
    end
  end

  private
  
  def self.having_invoiced_date_after(date_var)
    if date_var.present?
      where(invoiced_on: date_var..) 
    else
      all
    end
  end
    
  def self.having_invoiced_date_before(date_var)
    if date_var.present?
      where("invoiced_on <= ?", date_var)
    else
      all
    end
  end

  def self.having_visit_end_date_after(date_var)
    if date_var.present?
      joins(:visit)
      .where(Visit.arel_table[:ends_at].gteq(date_var))
    else
      all
    end
  end
  
  def self.having_visit_start_date_before(date_var)
    if date_var.present?
      joins(:visit)
      .where(Visit.arel_table[:starts_at].lteq(date_var))
    else
      all
    end
  end
  
  def self.sort_by_amount
    left_outer_joins(:invoice_payments).group('invoices.id').order('sum(invoice_payments.amount) asc')
  end
end
