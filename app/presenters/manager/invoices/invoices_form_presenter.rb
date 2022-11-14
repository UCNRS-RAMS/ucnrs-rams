# frozen_string_literal: true

class Manager::Invoices::InvoicesFormPresenter
  def initialize(visit:, form: nil)
    @form = form || InvoiceForm.new
    @visit = visit
  end

  attr_reader :form, :visit
  delegate_missing_to :visit

  def amenity_presenter(amenity, amenity_visit)
    Visits::AmenityPresenter.new(amenity, form: [amenity_visit])
  end

  def visit_date_range
    if starts_at.present? && ends_at.present?
      DateRangePresenter.value(start_date: starts_at.to_date, end_date: ends_at.to_date)
    end
  end

  def project_team_members
    @project_team_members ||= project.team_memberships
      .includes([:user, :institution])
      .can_receive_invoice
      .map do |team_membership|
      Manager::Projects::TeamMembershipPresenter.new(
        team_membership,
        reserve: reserve,
      )
    end
  end

  def amenities_total
    "$#{value(amenity_visits.sum(&:subtotal))}"
  end

  private

  def value(num)
    format("%0.2f", num)
  end
end
