# frozen_string_literal: true

class Mail::Manager::InvoiceEmailPresenter
  def initialize(invoice:, email_params:)
    @invoice = invoice
    @email_params = email_params
  end

  def email_to
    email_params[:email_to_list]
  end

  def email_cc
    if email_params[:cc_personnel]
      personnel_receiving_invoice_email
        .map { |personnel| personnel.user.email }
        .reject(&:blank?)

    else
      []

    end
  end

  def email_subject
    email_params[:subject] || email_params[:default_subject]
  end

  def email_body
    email_params[:body]
  end

  def email_attachment_name
    email_params[:attachment_name]
  end

  def email_attachment
    email_params[:attachment]
  end

  private

  attr_reader :email_params, :invoice

  def personnel_receiving_invoice_email
    ReservePersonnel
      .includes(:user)
      .where(
        reserve: invoice.visit.reserve,
        receive_invoice_email: true,
      )
      .map { |personnel| PersonnelPresenter.new(personnel) }
  end
end
