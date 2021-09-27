class ChangeReserve < ActiveRecord::Migration[6.1]
  def change
    
    
rename_column :reserves, :ReserveID, :id
rename_column :reserves, :ReserveID, :reserve_name
rename_column :reserves, :NickName, :short_name
rename_column :reserves, :PulldownName, :pulldown_name
rename_column :reserves, :ManagingCampus, :managing_campus_id
rename_column :reserves, :Department, :department  
    
add_column :reserves, :administrative_group_name, :varchar 
add_column :reserves, :administrative_group_name_acronym, :varchar 
add_column :reserves, :administrative_group_state, :varchar 
    
rename_column :reserves, :AddrLine1, :address_line_1
rename_column :reserves, :AddrLine2, :address_line_2
rename_column :reserves, :City, :address_city
rename_column :reserves, :State, :address_state  
rename_column :reserves, :PostalCode, :address_postal_code
rename_column :reserves, :Country, :address_country
        
add_column :reserves, :address_state_id, :int 
add_column :reserves, :address_country_id, :int 
						
rename_column :reserves, :CheckPayableName, :check_payable_to_name 
rename_column :reserves, :BillLine1, :billing_address_line_1
rename_column :reserves, :BillLine2, :billing_address_line_2  
rename_column :reserves, :BillCity, :billing_address_city
rename_column :reserves, :BillState, :billing_address_state
rename_column :reserves, :BillPostalCode, :billing_address_postal_code
rename_column :reserves, :BillCountry, :billing_address_country  
    
add_column :reserves, :billing_address_state_id, :int 
add_column :reserves, :billing_address_country_id, :int 
	
rename_column :reserves, :ApplicationEMailAddress, :reserve_rams_email_address
rename_column :reserves, :ReserveEmailAddress, :reserve_email_address
rename_column :reserves, :Telephone, :phone_number
rename_column :reserves, :Facsimile, :fax_number  
rename_column :reserves, :HomePageURL, :home_page_url_address 
rename_column :reserves, :IconURL, :logo_url_address 

rename_column :reserves, :Directions, :directions
rename_column :reserves, :Rules, :rules
rename_column :reserves, :Rates, :rates
rename_column :reserves, :DirectionsURL, :directions_url_address 
rename_column :reserves, :RulesURL, :rules_url_address 
rename_column :reserves, :RatesURL, :rates_url_address 
    
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
rename_column :reserves, :OutsideReservationSystemURL, :outside_reservation_system_url_address 
rename_column :reserves, :OutsideReservationSystemText, :outside_reservation_system_url_text 
rename_column :reserves, :DOI, :digital_object_identifier 
rename_column :reserves, :GoogleCalendarID, :google_calendar_id 
rename_column :reserves, :ReserveMessageOnOff, :reserve_alert_message_on_off 
rename_column :reserves, :ReserveMessage, :reserve_alert_message     
rename_column :reserves, :CodeOfConductURL, :code_of_conduct_url_address 
rename_column :reserves, :ZoteroURL, :zotero_url_address 
rename_column :reserves, :ZoteroLogin, :zotero_login_name 
rename_column :reserves, :ZoteroPassword, :zotero_password     
rename_column :reserves, :FacilityGroup, :facility_group_name  
rename_column :reserves, :InternetStatus, :internet_status   
rename_column :reserves, :DropBoxLogin, :drop_box_login_name
rename_column :reserves, :DropBoxPassword, :drop_box_password
rename_column :reserves, :DropBoxRequestURL, :drop_box_request_url_address
rename_column :reserves, :AssetGroupLabel1, :asset_group_label_1
rename_column :reserves, :AssetGroupLabel2, :asset_group_label_2
rename_column :reserves, :AssetGroupLabel3, :asset_group_label_3
rename_column :reserves, :AssetGroupLabel4, :asset_group_label_4
rename_column :reserves, :AssetGroupLabel5, :asset_group_label_5
rename_column :reserves, :ContactInfoText, :how_to_contact
rename_column :reserves, :FacilitySpecialNeedsStatement, :special_needs_statement
change_column_comment :reserves, special_needs_statement:,  to: "Reserve personalized message text dispalyed with this field"


# DEPRICATED field will not be deleted but have thier COMMET box changed    

 change_column_comment :reserves, EmailAttachment:,  to: "DEPRICATED"
 change_column_comment :reserves, EmailFormat:,  to: "DEPRICATED"
 change_column_comment :reserves, PublicAppFormat:,  to: "DEPRICATED"
 change_column_comment :reserves, PublicDayUseAppsAccepted:,  to: "DEPRICATED"
 change_column_comment :reserves, PublicDayUseAppNumber:,  to: "DEPRICATED"
 change_column_comment :reserves, CollectBirthDate:,  to: "DEPRICATED"
 change_column_comment :reserves, CollectCAProjectSponsor:,  to: "DEPRICATED"
 change_column_comment :reserves, CollectCellPhone:,  to: "DEPRICATED"
 change_column_comment :reserves, CollectGender:,  to: "DEPRICATED"
 change_column_comment :reserves, CollectHousingConcerns:,  to: "DEPRICATED"
 change_column_comment :reserves, CollectIDNumber:,  to: "DEPRICATED"
 change_column_comment :reserves, CollectPermanentAddress:,  to: "DEPRICATED"
 change_column_comment :reserves, CollectSensorData:,  to: "DEPRICATED"
 change_column_comment :reserves, UserMailingListSettings:,  to: "DEPRICATED"
 change_column_comment :reserves, AllowMailSpoofing:,  to: "DEPRICATED"
 change_column_comment :reserves, Map1URL:,  to: "DEPRICATED - WIll store in separate table."
 change_column_comment :reserves, Map2URL:,  to: "DEPRICATED - WIll store in separate table."
 change_column_comment :reserves, Map3URL:,  to: "DEPRICATED - WIll store in separate table."
 change_column_comment :reserves, Map1Caption:,  to: "DEPRICATED - WIll store in separate table."
 change_column_comment :reserves, Map2Caption:,  to: "DEPRICATED - WIll store in separate table."
 change_column_comment :reserves, Map3Caption:,  to: "DEPRICATED - WIll store in separate table."
 change_column_comment :reserves, UseCAPermitQuestions:,  to: "DEPRICATED"
 change_column_comment :reserves, UseAdditionalAppQuestions:,  to: "DEPRICATED"
 change_column_comment :reserves, AccountantID:,  to: "DEPRICATED"
 change_column_comment :reserves, UAVContactPerson, to: "DEPRICATED"
 change_column_comment :reserves, UAVContactPersonEmail, to: "DEPRICATED"
 change_column_comment :reserves, IACUCContactPerson, to: "DEPRICATED"
 change_column_comment :reserves, IACUCContactPersonEmail, to: "DEPRICATED"
 
    
# Geographic Data about reserve moved to reserve_locations table and thus will be removed from the final table.

rename_column :reserves, :Latitude, :geographic_latitude
rename_column :reserves, :Longitude, :geographic_longitude
rename_column :reserves, :LatDeg, :geographic_latitude_degree
rename_column :reserves, :LatMin, :geographic_latitude_minute
rename_column :reserves, :LatSec, :geographic_latitude_second
rename_column :reserves, :LatHemisphere, :geographic_latitude_hemisphere
rename_column :reserves, :LongDeg, :geographic_longitude_degree
rename_column :reserves, :LongMin, :geographic_longitude_minute
rename_column :reserves, :LongSec, :geographic_longitude_second
rename_column :reserves, :LongHemisphere, :geographic_longitude_hemisphere
rename_column :reserves, :UTMX, :geographic_utm_x
rename_column :reserves, :UTMY, :geographic_utm_y
rename_column :reserves, :UTMZone, :geographic_utm_zone
rename_column :reserves, :DistanceToManagingCampus, :geographic_distance_to_managing_campus
rename_column :reserves, :AverageDistanceToCampus, :geographic_average_distance_to_campus
rename_column :reserves, :DistanceToUCB, :geographic_distance_to_ucb
rename_column :reserves, :DistanceToUCD, :geographic_distance_to_ucd
rename_column :reserves, :DistanceToUCI, :geographic_distance_to_uci
rename_column :reserves, :DistanceToUCM, :geographic_distance_to_ucm
rename_column :reserves, :DistanceToUCLA, :geographic_distance_to_ucla
rename_column :reserves, :DistanceToUCR, :geographic_distance_to_ucr
rename_column :reserves, :DistanceToUCSB, :geographic_distance_to_ucsb
rename_column :reserves, :DistanceToUCSC, :geographic_distance_to_ucsc
rename_column :reserves, :DistanceToUCSD, :geographic_distance_to_ucsd

change_column_comment :reserves, geographic_latitude, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_longitude, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_latitude_degree, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_latitude_minute, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_latitude_second, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_latitude_hemisphere, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_longitude_degree, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_longitude_minute, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_longitude_second, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_longitude_hemisphere, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_utm_x, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_utm_y, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_utm_zone, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_distance_to_managing_campus, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_average_distance_to_campus, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_distance_to_ucb, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_distance_to_ucd, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_distance_to_uci, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_distance_to_ucm, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_distance_to_ucla, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_distance_to_ucr, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_distance_to_ucsb, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_distance_to_ucsc, to: "DEPRICATED moved to reserve_locations"
change_column_comment :reserves, geographic_distance_to_ucsd, to: "DEPRICATED moved to reserve_locations"


# ------------------
# update other tables referenece to RESERVEID
# ------------------
rename_column :ARPart5Publications, :ReserveID, :reserve_id
rename_index :ARPart5Publications, :Reserves, :reserve
rename_column :ARParts, :ReserveID, :reserve_id
rename_index :ARParts, :ReserveYear, :reserve_year
rename_column :ActPeople, :ReserveID, :reserve_id
rename_index :ActPeople, :Reserves, :reserve
rename_column :AppPermits, :ReservePermitID, :id
rename_index :AppPermits, :Reserves, :reserve
rename_index :Applications, :ReserveID, :reserve
rename_column :Equipment, :ReserveID, :reserve_id
rename_column :Grants, :ReserveID, :reserve_id
rename_column :InvoicesTransition, :ReserveID, :reserve_id
rename_column :NRSPersonnel, :ReserveID, :reserve_id
rename_index :NRSPersonnel, :Reserves, :reserve
rename_column :ReserveAssetRateCategories, :ReserveID, :reserve_id
rename_column :ReserveAssets, :ReserveID, :reserve_id
rename_column :ReserveAssets, :ReserveIDTemp, :reserve_id_temp
rename_index :ReserveAssets, :Reserve, :reserve
rename_index :ReserveAssets, :ReserveSortOrder, :reserve_sort_order
rename_column :ReservePermits, :ReserveID, :reserve_id
rename_column :ReservePermits, :ReserveIDTemp, :reserve_id_temp
rename_column :ReserveQuestions, :ReserveID, :reserve_id
rename_column :Waivers, :ReserveID, :reserve_id
rename_column :Waivers, :ReserveIDTemp, :reserve_id_temp

# ------------------
# Done at previous Update for visits and project tables
# ------------------
# rename_column :activities, :ReserveID, :reserve_id
# rename_index :activities, :ReserveID, :reserve
# rename_column :Applications, :ReserveID, :reserve_id



