# frozen_string_literal: true

# Long free-text fields: TEXT keeps them out of the 65,535-byte row-size
# budget that a wide VARCHAR reserves in full. Length is enforced by model
# validations instead.
class ChangeStudyAreasToText < ActiveRecord::Migration[8.1]
  def up
    change_column :visits, :study_area, :text
    change_column :projects, :method_study_area, :text
  end

  def down
    change_column :visits, :study_area, :string
    change_column :projects, :method_study_area, :string, limit: 10_000
  end
end
