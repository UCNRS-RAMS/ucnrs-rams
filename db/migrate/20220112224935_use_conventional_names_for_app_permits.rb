class UseConventionalNamesForAppPermits < ActiveRecord::Migration[6.1]
  def change
    rename_table :AppPermits, :application_permit_answers
    rename_column :application_permit_answers, :AppPermitID, :id
    rename_column :application_permit_answers, :reserve_id, :reserve_permit_id
    rename_column :application_permit_answers, :PermitNumber, :permit_number
    rename_column :application_permit_answers, :PermitDate, :issued_on
    rename_column :application_permit_answers, :PermitExpireDate, :expires_on
    rename_column :application_permit_answers, :Vertebrates, :vertebrates
    rename_column :application_permit_answers, :PermitAnswer, :answer

    change_table_comment :application_permit_answers, from: nil, to: "Obsolete table, use project_permit_answers."
  end
end
