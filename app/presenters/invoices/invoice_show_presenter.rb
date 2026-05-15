# frozen_string_literal: true

class Invoices::InvoiceShowPresenter
  def initialize(invoice:)
    @invoice = invoice
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

  def amenity_visits
    invoice.amenity_visits.map do |amenity_visit|
      AmenityVisitPresenter.new(amenity_visit)
    end
  end

  def invoice_payments
    @invoice_payments ||= @invoice&.invoice_payments&.map { |payment| InvoicePaymentPresenter.new(payment) }
  end

  def balance
    invoice.amenity_visits.sum(&:subtotal) - invoice_payments.sum(&:amount)
  end

  def balance_class
    case balance <=> 0
    when -1
      "negative-balance"
    when 1
      "positive-balance"
    else
      "default-balance"
    end
  end

  private

  delegate :reserve, :project, to: :visit, private: true
  delegate :invoice_recipients, :id, :modify_number, :visit, to: :invoice, private: true
  delegate :id, to: :project , prefix: true, private: true

  def recipients_user_ids
    invoice_recipients.pluck(:user_id)
  end

  def recipients_scope
    project
      .team_memberships
      .includes([:user, :institution])
      .where(user_id: recipients_user_ids)
  end
end
