class State < ApplicationRecord
  belongs_to :country
  has_many :institutions, inverse_of: :state, dependent: :nullify
  has_many :user_address_states, class_name: "User", foreign_key: :address_state_id
  has_many :user_billing_address_states, class_name: "User", foreign_key: :billing_address_state_id
end
