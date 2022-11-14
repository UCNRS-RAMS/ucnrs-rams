# frozen_string_literal: true

class Manager::Invoices::InvoiceShowPresenter
  def initialize(invoice:, current_user:)
    @invoice = invoice
    @current_user = current_user
  end

  delegate :name, to: :reserve , prefix: true
  delegate :title, to: :project, prefix: true
  delegate :purpose_of_visit, to: :visit
  delegate :notes, to: :invoice

  def title
    I18n.t("manager.invoices.show.invoice", id: id, version: modify_number)
  end

  def visit_date_range
    Manager::VisitShowPresenter.new(visit: visit, current_user: @current_user).visit_date_range
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


  private

  delegate :reserve, :project, to: :visit, private: true
  delegate :invoice_recipients, :id, :modify_number, :visit, :amenity_visits, to: :invoice, private: true
  delegate :id, to: :project , prefix: true, private: true
  
  attr_reader :invoice, :current_user

  def recipients_user_ids
    invoice_recipients.pluck(:user_id)
  end

  def recipients_scope
    project.team_memberships.where(user_id: recipients_user_ids)
  end
end
