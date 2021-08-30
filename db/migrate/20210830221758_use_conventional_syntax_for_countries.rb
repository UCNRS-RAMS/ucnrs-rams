class UseConventionalSyntaxForCountries < ActiveRecord::Migration[6.1]
  def change
    rename_table :Countries, :countries_
    rename_table :countries_, :countries
    rename_column :countries, :Name, :name
    rename_column :countries, :Code, :code
    rename_column :countries, :Subunit, :subunit

    rename_column :countries, :CountryID, :id
    rename_column :Institutions, :CountryID, :country_id
    rename_column :States, :CountryID, :country_id
    rename_column :users, :AddrCountryID, :address_country_id
    rename_column :users, :BillingAddrCountryID, :billing_address_country_id

    rename_index :countries, :Name, :name
    rename_index :States, :Country, :country
  end
end
