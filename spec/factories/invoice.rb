FactoryBot.define do
  factory :invoice do
    association :visit
    notes {"Note for invoice"}
    balance_due { 0.0 }

    transient do
      recipients { [] }
    end

    after(:build) do |invoice, evaluator|
      evaluator.recipients.each do |member|
        invoice.invoice_recipients << build(
          :invoice_recipient,
          user: member,
          invoice: invoice,
        )
      end
    end
  end
end
