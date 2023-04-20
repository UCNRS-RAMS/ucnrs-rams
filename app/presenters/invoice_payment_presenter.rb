class InvoicePaymentPresenter
  def initialize(payment)
    @payment = payment
  end

  attr_reader :payment

  delegate_missing_to :payment

  def paid_on
    payment.paid_on.strftime("%b %d, %Y")
  end
end
