class Manager::Invoices::EmailsNewPresenter
  def initialize(invoice:)
    @invoice = invoice
  end

  delegate :id, :visit, to: :invoice, prefix: true
  delegate :reserve, to: :invoice_visit, prefix: true

  attr_reader :invoice

  def invoice_visit_project_team_membership
    team_membership_scope.map do |team_membership|
      ProjectTeamMembershipPresenter.new(
        team_membership
      )
    end
  end

  def email_default_subject
    "#{I18n.t("manager.invoices.emails.new.invoice")} ##{invoice_id} - #{invoice_visit_reserve.name}"
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

  def email_attachment_name
    "rams_invoice_#{pis_names.first.downcase.parameterize(separator: '_')}#{"_et_al" if pis_names.count > 1}_#{invoice_id}.pdf"
  end

  private

  def team_membership_scope
    @team_membership_scope ||= ProjectTeamMembership
      .where(project: invoice_visit.project_id)
      .includes([:user, :institution])
      .by_project_role
  end

  def pis_names
    invoice_visit_project_team_membership
      .find_all { |team_member| team_member.is_principal_investigator }
      .map(&:user_full_name)
  end
end
