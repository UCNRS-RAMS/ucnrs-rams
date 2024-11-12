# frozen_string_literal: true

class Manager::Invoices::InvoiceShowPresenter
  def initialize(invoice:, current_user:)
    @invoice = invoice
    @current_user = current_user
  end

  delegate :name, to: :reserve, prefix: true
  delegate :title, to: :project, prefix: true
  delegate :purpose_of_visit, to: :visit
  delegate :notes, to: :invoice
  delegate :id, to: :invoice, prefix: true

  attr_reader :invoice, :current_user

  def title
    I18n.t("manager.invoices.show.invoice", id: id, version: modify_number)
  end

  def link_params(path: "#", method: nil, data: nil, icon: nil, icon_alt: nil, classes: nil)
    {
      path: path,
      method: method,
      data: data,
      icon: icon,
      icon_alt: icon_alt,
      classes: classes,
    }
  end

  def visit_date_range
    DateRangePresenter.new(
      start_date: visit.starts_at,
      end_date: visit.ends_at,
    ).value("date_range.different_years")
  end

  def recipients
    recipients_scope.map do |recipient|
      Projects::TeamMembershipPresenter.new(recipient)
    end
  end

  def amenity_visit_presenters
    amenity_visits.map do |amenity_visit|
      AmenityVisitPresenter.new(amenity_visit)
    end
  end

  def amenities_total
    InvoicePresenter.new(invoice).amenities_total
  end

  def invoice_payments
    @invoice_payments ||= @invoice&.invoice_payments.map { |payment| InvoicePaymentPresenter.new(payment) }
  end

  def balance
    balance ||= calculate_balance
  end

  def balance_class
    case calculate_balance <=> 0
    when -1
      "negative_balance"
    when 1
      "positive_balance"
    else
      "default_balance"
    end
  end

  private

  delegate :reserve,
    :project,
    to: :visit

  delegate :invoice_recipients,
    :id,
    :modify_number,
    :visit,
    :amenity_visits,
    to: :invoice

  delegate :id,
    to: :project,
    prefix: true

  def recipients_user_ids
    invoice_recipients.pluck(:user_id)
  end

  def recipients_scope
    project.team_memberships.includes([:user, :institution]).where(user_id: recipients_user_ids)
  end

  def payments_amount_total
    value(invoice_payments.pluck(:amount).sum).to_i
  end

  def amenity_visit_total
    "#{value(invoice.amenity_visits.sum(&:subtotal))}"
  end

  def calculate_balance
    amenity_visit_total.to_i - payments_amount_total
  end

  def value(num)
    format("%0.2f", num)
  end

  def sign(number)
    number.negative? ? "-" : ""
  end
end
