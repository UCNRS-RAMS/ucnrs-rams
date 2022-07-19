class ReservePermit < ApplicationRecord
  belongs_to :reserve
  belongs_to :permit

  def self.with_permit_authority_column
    select("reserve_permits.*, permits.authority AS permit_authority")
      .left_joins(:permit)
  end

  def self.order_by_permit_authority
      left_joins(:permit)
      .order(Permit.arel_table[:authority])
  end
end
