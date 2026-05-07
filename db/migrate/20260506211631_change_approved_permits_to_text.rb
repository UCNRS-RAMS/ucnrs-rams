class ChangeApprovedPermitsToText < ActiveRecord::Migration[8.1]
  def up
    change_column(:projects, :approved_permits, :text)
  end

  def down
    # intentionally empty:
    # text -> string would truncate any rows already exceeding 255 chars
  end
end
