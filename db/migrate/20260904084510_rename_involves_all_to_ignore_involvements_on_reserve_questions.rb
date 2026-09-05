class RenameInvolvesAllToIgnoreInvolvementsOnReserveQuestions < ActiveRecord::Migration[8.1]
  def change
    rename_column :reserve_questions, :involves_all, :ignore_involvements
    change_column_null :reserve_questions, :ignore_involvements, false, false
    change_column_default :reserve_questions, :ignore_involvements, from: nil, to: true
  end
end
