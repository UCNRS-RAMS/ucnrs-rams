class UsePolicy < ApplicationRecord
  enum agreement_type: {
    reserve_use_agreement: "Reserve Use Agreement",
    code_of_conduct_agreement: "Code of Conduct Agreement",
    data_management_agreement: "Data Management Agreement"
  }

  def self.in_order
    order(:sort_order)
  end
end
