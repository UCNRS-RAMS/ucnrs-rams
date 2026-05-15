class UseConventionalNamesForReserves < ActiveRecord::Migration[6.1]
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def change
    rename_column :reserves, :ReserveID, :id
    reversible do |dir|
      dir.up do
        change_column :reserves, :id, :integer, auto_increment: true
      end
      dir.down do
        change_column :reserves, :id, :integer, auto_increment: false, default: nil
      end
    end
    rename_column :reserves, :Name, :name
    rename_column :reserves, :NickName, :short_name
    rename_column :reserves, :PulldownName, :pulldown_name
    rename_column :reserves, :ManagingCampus, :managing_campus_id
    rename_column :reserves, :Department, :department  

    rename_column :visits, :ReserveID, :reserve_id
    rename_index :visits, :ReserveID, :reserve

    add_column :reserves, :administrative_group_name, :string 
    add_column :reserves, :administrative_group_name_acronym, :string 
    add_column :reserves, :administrative_group_state, :string 

    rename_column :reserves, :AddrLine1, :address_line_1
    rename_column :reserves, :AddrLine2, :address_line_2
    rename_column :reserves, :City, :address_city
    rename_column :reserves, :PostalCode, :address_postal_code

    add_column :reserves, :address_state_id, :integer
    add_column :reserves, :address_country_id, :integer

    rename_column :reserves, :CheckPayableName, :check_payable_to_name 
    rename_column :reserves, :BillLine1, :billing_address_line_1
    rename_column :reserves, :BillLine2, :billing_address_line_2  
    rename_column :reserves, :BillCity, :billing_city
    rename_column :reserves, :BillPostalCode, :billing_address_postal_code

    add_column :reserves, :billing_address_state_id, :integer
    add_column :reserves, :billing_address_country_id, :integer

    reversible do |dir|
      dir.up do
        execute("UPDATE reserves JOIN states ON reserves.State = states.code SET reserves.address_state_id = states.id")
        execute("UPDATE reserves JOIN countries ON reserves.Country = countries.code SET reserves.address_country_id = countries.id")
        execute("UPDATE reserves JOIN states ON reserves.State = states.code SET reserves.billing_address_state_id = states.id")
        execute("UPDATE reserves JOIN countries ON reserves.Country = countries.code SET reserves.billing_address_country_id = countries.id")
      end
      dir.down do
        execute("UPDATE reserves JOIN states ON reserves.address_state_id = states.id SET reserves.BillState = states.code")
        execute("UPDATE reserves JOIN countries ON reserves.address_country_id = countries.id SET reserves.BillCountry = countries.code")
        execute("UPDATE reserves JOIN states ON reserves.billing_address_state_id = states.id SET reserves.BillState = states.code")
        execute("UPDATE reserves JOIN countries ON reserves.billing_address_country_id = countries.id SET reserves.BillCountry = countries.code")
      end
    end

    rename_column :reserves, :ApplicationEMailAddress, :applicaton_email_address
    rename_column :reserves, :ReserveEmailAddress, :email_address
    rename_column :reserves, :Telephone, :phone_number
    rename_column :reserves, :Facsimile, :fax_number  
    rename_column :reserves, :HomePageURL, :home_page_url 
    rename_column :reserves, :IconURL, :logo_url 

    rename_column :reserves, :Directions, :directions
    rename_column :reserves, :Rules, :rules
    rename_column :reserves, :Rates, :rates
    rename_column :reserves, :DirectionsURL, :directions_url 
    rename_column :reserves, :RulesURL, :rules_url 
    rename_column :reserves, :RatesURL, :rates_url 

    rename_column :reserves, :ResearchAppsAccepted, :research_projects_accepted 
    rename_column :reserves, :ClassAppsAccepted, :class_projects_accepted 
    rename_column :reserves, :PublicAppsAccepted, :public_projects_accepted 
    rename_column :reserves, :HousingAppsAccepted, :housing_projects_accepted 
    rename_column :reserves, :conference_apps_accepted, :conference_projects_accepted 
    rename_column :reserves, :PublicCalendar, :public_calendar_access 
    rename_column :reserves, :EMailAcceptMessage, :approval_message 
    rename_column :reserves, :EmailMessage2, :email_message_2  
    rename_column :reserves, :EmailMessage3, :email_message_3 
    rename_column :reserves, :EmailMessage4, :email_message_4 
    rename_column :reserves, :InvoiceText, :invoice_message 
    rename_column :reserves, :TaxIDNumber, :tax_id_number       
    rename_column :reserves, :InvoiceTrailer, :invoice_message_footer 
    rename_column :reserves, :YearIncludedInNRS, :year_reserve_established 
    rename_column :reserves, :ShowRateTable, :show_rate_table 
    rename_column :reserves, :LDAP, :ldap_address 
    rename_column :reserves, :OutsideReservationSystemURL, :outside_reservation_system_url 
    rename_column :reserves, :OutsideReservationSystemText, :outside_reservation_system_text 
    rename_column :reserves, :DOI, :doi
    rename_column :reserves, :GoogleCalendarID, :google_calendar_id 
    rename_column :reserves, :ReserveMessageOnOff, :reserve_alert_message_enabled
    rename_column :reserves, :ReserveMessage, :reserve_alert_message     
    rename_column :reserves, :CodeOfConductURL, :code_of_conduct_url 
    rename_column :reserves, :ZoteroURL, :zotero_url 
    rename_column :reserves, :ZoteroLogin, :zotero_login 
    rename_column :reserves, :ZoteroPassword, :zotero_password     
    rename_column :reserves, :FacilityGroup, :facility_group_name  
    rename_column :reserves, :InternetStatus, :internet_status   
    rename_column :reserves, :DropBoxLogin, :drop_box_login
    rename_column :reserves, :DropBoxPassword, :drop_box_password
    rename_column :reserves, :DropBoxRequestURL, :drop_box_request_url
    rename_column :reserves, :AssetGroupLabel1, :asset_group_label_1
    rename_column :reserves, :AssetGroupLabel2, :asset_group_label_2
    rename_column :reserves, :AssetGroupLabel3, :asset_group_label_3
    rename_column :reserves, :AssetGroupLabel4, :asset_group_label_4
    rename_column :reserves, :AssetGroupLabel5, :asset_group_label_5
    rename_column :reserves, :ContactInfoText, :how_to_contact
    rename_column :reserves, :FacilitySpecialNeedsStatement, :special_needs_statement

    change_column_comment :reserves, :special_needs_statement, to: "Reserve personalized message text dispalyed with this field", from: nil

    # DEPRECATED field will not be deleted but have their COMMENT box changed    

    change_column_comment :reserves, :EmailAttachment, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :EmailFormat, to: "DEPRECATED", from: "Email Version of App"
    change_column_comment :reserves, :PublicAppFormat, to: "DEPRECATED", from:  "0 = short form  1= long form"
    change_column_comment :reserves, :PublicDayUseAppsAccepted, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :PublicDayUseAppNumber, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :CollectBirthDate, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :CollectCAProjectSponsor, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :CollectCellPhone, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :CollectGender, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :CollectHousingConcerns, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :CollectIDNumber, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :CollectPermanentAddress, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :CollectSensorData, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :UserMailingListSettings, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :AllowMailSpoofing, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :Map1URL, to: "DEPRECATED - WIll store in separate table.", from: nil
    change_column_comment :reserves, :Map2URL, to: "DEPRECATED - WIll store in separate table.", from: nil
    change_column_comment :reserves, :Map3URL, to: "DEPRECATED - WIll store in separate table.", from: nil
    change_column_comment :reserves, :Map1Caption, to: "DEPRECATED - WIll store in separate table.", from: nil
    change_column_comment :reserves, :Map2Caption, to: "DEPRECATED - WIll store in separate table.", from: nil
    change_column_comment :reserves, :Map3Caption, to: "DEPRECATED - WIll store in separate table.", from: nil
    change_column_comment :reserves, :UseCAPermitQuestions, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :UseAdditionalAppQuestions, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :AccountantID, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :UAVContactPerson, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :UAVContactPersonEmail, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :IACUCContactPerson, to: "DEPRECATED", from: nil
    change_column_comment :reserves, :IACUCContactPersonEmail, to: "DEPRECATED", from: nil

    # Geographic Data about reserve moved to reserve_locations table and thus will be removed from the final table.

    rename_column :reserves, :Latitude, :latitude
    rename_column :reserves, :Longitude, :longitude
    add_column :reserves, :latitude_degrees, "INT GENERATED ALWAYS AS (FLOOR(ABS(latitude)))"
    add_column :reserves, :latitude_minutes, "INT GENERATED ALWAYS AS (FLOOR(MOD(ABS(latitude), 1) * 60))"
    add_column :reserves, :latitude_seconds, "FLOAT GENERATED ALWAYS AS (MOD(MOD(ABS(latitude), 1) * 60, 1) * 60)"
    add_column :reserves, :latitude_hemisphere, %q{VARCHAR(50) GENERATED ALWAYS AS (IF(latitude > 0, "N", "S"))}
    add_column :reserves, :longitude_degrees, "INT GENERATED ALWAYS AS (FLOOR(ABS(longitude)))"
    add_column :reserves, :longitude_minutes, "INT GENERATED ALWAYS AS (FLOOR(MOD(ABS(longitude), 1) * 60))"
    add_column :reserves, :longitude_seconds, "FLOAT GENERATED ALWAYS AS (MOD(MOD(ABS(longitude), 1) * 60, 1) * 60)"
    add_column :reserves, :longitude_hemisphere, %q{VARCHAR(50) GENERATED ALWAYS AS (IF(longitude > 0, "E", "W"))}

    change_column_comment :reserves, :LatDeg, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :LatMin, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :LatSec, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :LatHemisphere, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :LongDeg, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :LongMin, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :LongSec, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :LongHemisphere, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :UTMX, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :UTMY, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :UTMZone, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :DistanceToManagingCampus, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :AverageDistanceToCampus, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :DistanceToUCB, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :DistanceToUCD, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :DistanceToUCI, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :DistanceToUCM, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :DistanceToUCLA, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :DistanceToUCR, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :DistanceToUCSB, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :DistanceToUCSC, to: "DEPRECATED moved to reserve_locations", from: nil
    change_column_comment :reserves, :DistanceToUCSD, to: "DEPRECATED moved to reserve_locations", from: nil

    # ------------------
    # update other tables reference to RESERVEID
    # ------------------
    rename_column :ARPart5Publications, :ReserveID, :reserve_id
    rename_column :ARParts, :ReserveID, :reserve_id
    rename_column :ActPeople, :ReserveID, :reserve_id
    rename_column :AppPermits, :ReservePermitID, :reserve_id
    rename_column :Equipment, :ReserveID, :reserve_id
    rename_column :Grants, :ReserveID, :reserve_id
    rename_column :InvoicesTransition, :ReserveID, :reserve_id
    rename_column :NRSPersonnel, :ReserveID, :reserve_id
    rename_column :ReserveAssetRateCategories, :ReserveID, :reserve_id
    rename_column :ReserveAssets, :ReserveID, :reserve_id
    rename_column :ReserveAssets, :ReserveIDTemp, :reserve_id_temp
    rename_column :ReservePermits, :ReserveID, :reserve_id
    rename_column :ReservePermits, :ReserveIDTemp, :reserve_id_temp
    rename_column :ReserveQuestions, :ReserveID, :reserve_id
    rename_column :Waivers, :ReserveID, :reserve_id
    rename_column :Waivers, :ReserveIDTemp, :reserve_id_temp

    rename_index :ARPart5Publications, :Reserves, :reserve
    rename_index :ARParts, :ReserveYear, :reserve_year
    rename_index :ActPeople, :Reserves, :reserve
    rename_index :AppPermits, :Reserves, :reserve
    rename_index :NRSPersonnel, :Reserve, :reserve
    rename_index :ReserveAssets, :Reserve, :reserve
    rename_index :ReserveAssets, :ReserveSortOrder, :reserve_sort_order
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
