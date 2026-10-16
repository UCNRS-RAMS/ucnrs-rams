# frozen_string_literal: true

class ApiClientReserve < ApplicationRecord
  belongs_to :api_client
  belongs_to :reserve

  validates :reserve_id, uniqueness: { scope: :api_client_id }
end
