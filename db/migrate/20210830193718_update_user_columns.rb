class UpdateUserColumns < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :Gender, :gender_identity
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE users MODIFY COLUMN gender_identity enum('Male','Female','Non-binary','Other','Prefer not to state');
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE users MODIFY COLUMN gender_identity enum('Female','Male','Non-binary','');
        SQL
      end
    end
    rename_column :users, :NameFirst, :first_name
    rename_column :users, :NameMiddle, :middle_name
    rename_column :users, :NameLast, :last_name
    rename_column :users, :Title, :title
    rename_column :users, :AddrLine1, :address_line_1
    rename_column :users, :AddrLine2, :address_line_2
    rename_column :users, :AddrCity, :address_city
    rename_column :users, :AddrPostalCode, :address_postal_code
    rename_column :users, :CellPhone, :phone_number
    rename_column :users, :OtherPhone, :secondary_phone_number
    rename_column :users, :Birthdate, :date_of_birth
    rename_column :users, :IdentificationNumber, :identification_number
    rename_column :users, :HousingConcerns, :housing_concerns
    rename_column :users, :Department, :department
    rename_column :users, :BillingPersonName, :billing_person_full_name
    rename_column :users, :BillingPersonPhone, :billing_person_phone_number
    rename_column :users, :BillingPersonEmail, :billing_person_email
    rename_column :users, :BillingAddrLine1, :billing_address_address_line_1
    rename_column :users, :BillingAddrLine2, :billing_address_address_line_2
    rename_column :users, :BillingAddrCity, :billing_address_city
    rename_column :users, :BillingAddrPostalCode, :billing_address_postal_code
    rename_column :users, :RecordComplete, :record_complete
    rename_column :users, :AdministrativeNotes, :administrative_notes
    rename_column :users, :Advisor, :advisor
    rename_column :users, :ORCID, :orcid
    rename_column :users, :DateCreated, :date_created
    rename_column :users, :EmergencyContact, :emergency_contact_full_name
    rename_column :users, :EmergencyTelephone, :emergency_contact_phone_number
    rename_column :users, :Role, :role

    add_column :users, :accessibility_requirements, :text
    add_column :users, :billing_address_same_as_current, :boolean
    add_column :users, :backup_email_address, :string
    add_column :users, :terms_accepted_at, :datetime, null: false
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE users ADD age_range enum('1-17', '18-25', '25-50', '50 or older');
        SQL
      end
      dir.down do
        remove_column :users, :age_range
      end
    end

    change_column_null :users, :first_name, false
    change_column_null :users, :last_name, false
    change_column_null :users, :address_line_1, false
    change_column_null :users, :address_city, false
    change_column_null :users, :address_postal_code, false
    change_column_null :users, :phone_number, false
    change_column_null :users, :emergency_contact_full_name, false
    change_column_null :users, :emergency_contact_phone_number, false
    change_column_null :users, :role, false

    remove_column :users, :PermAddrLine1, :string
    remove_column :users, :PermAddrLine2, :string
    remove_column :users, :PermAddrCity, :string
    remove_column :users, :PermAddrPostalCode, :string
    remove_column :users, :PermAddrStateID, :integer
    remove_column :users, :PermAddrCountryID, :integer
    remove_column :users, :Count, :integer
    remove_column :users, :NameGroup, :string
    remove_column :users, :FaxPhone, :string
  end
end
