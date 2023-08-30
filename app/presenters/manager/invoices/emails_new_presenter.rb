class Manager::Invoices::EmailsNewPresenter
  def initialize(invoice:, current_user:)
    @invoice = invoice
    @current_user = current_user
  end

  delegate :visit, to: :invoice, prefix: true

  attr_reader :invoice

  def invoice_visit_project
    invoice_visit.project
  end

  def invoice_visit_reserve
    invoice_visit.reserve
  end

  def invoice_visit_project_team_membership
    team_membership_scope.map do |team_membership|
      ProjectTeamMembershipPresenter.new(
        team_membership
      )
    end
  end

  def email_default_subject
    "Invoice ##{invoice.id} - #{invoice_visit.reserve.name}"
  end

  def email_default_body
    [].tap do |involves|
      if invoice_visit_reserve.check_payable_to_name.present?
        involves << "Make checks payable to: #{invoice_visit_reserve.check_payable_to_name}"
      end

      if invoice_visit_reserve.tax_id_number.present?
        involves << "Tax ID: #{invoice_visit_reserve.tax_id_number}"
      end

      if invoice_visit_reserve.invoice_message.present?
        involves << invoice_visit_reserve.invoice_message
      end
    end.join("\n\n")
  end

  private

  def team_membership_scope
    ProjectTeamMembership
      .where(project: invoice_visit.project_id)
      .includes([:user, :institution])
      .by_project_role
  end
end
