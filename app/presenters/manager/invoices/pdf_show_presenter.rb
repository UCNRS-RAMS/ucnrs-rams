class Manager::Invoices::PdfShowPresenter
  def initialize(invoice:)
    @invoice = InvoicePresenter.new invoice
  end

  delegate :visit, to: :invoice, prefix: true
  delegate :notes, to: :invoice, prefix: true

  attr_reader :invoice

  def invoice_visit_project
    invoice_visit.project
  end

  def invoice_visit_reserve
    ReservePresenter.new invoice_visit.reserve
  end

  def invoice_visit_project_team_membership
    team_membership_scope.map do |team_membership|
      ProjectTeamMembershipPresenter.new team_membership
    end
  end

  def address
    [].tap do |address|
      address << invoice_visit_reserve.full_address_line
      address << "Tel: #{invoice_visit_reserve.phone_number}"
    end.join("\n")
  end

  def billing_address
    invoice_visit_reserve.full_billing_address_line
  end

  def invoice_text
    [].tap do |body|
      if invoice_visit_reserve.check_payable_to_name.present?
        body << "Make checks payable to: #{invoice_visit_reserve.check_payable_to_name}"
      end

      if invoice_visit_reserve.tax_id_number.present?
        body << "Tax ID: #{invoice_visit_reserve.tax_id_number}"
      end
    end.join("\n\n")
  end

  def invoice_message
    invoice_visit_reserve.invoice_message
  end

  def invoice_date
    invoice.invoiced_on
  end

  def invoice_recipients
    invoice.invoice_recipients.includes([user: :institution])
  end

  def invoice_amenity_visits
    @invoice_amenity_visits ||= invoice
      .amenity_visits
      .includes([:amenity])
      .map do |amenity_visit|
        AmenityVisitPresenter.new amenity_visit
      end
  end

  def invoice_payments
    @invoice_payments ||= invoice
      .invoice_payments
      .map do |invoice_payment|
        InvoicePaymentPresenter.new invoice_payment
      end
  end

  def invoice_balance
    balance ||= amenity_visit_total - invoice_payments_total
  end

  private

  def team_membership_scope
    ProjectTeamMembership
      .where(project: invoice_visit.project_id)
      .includes([:user, :institution])
      .by_project_role
  end

  def invoice_payments_total
    invoice_payments.sum(&:amount)
  end

  def amenity_visit_total
    invoice_amenity_visits.sum(&:subtotal)
  end
end
