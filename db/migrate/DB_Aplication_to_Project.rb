class ChangeApplicationsToProjects < ActiveRecord::Migration[6.1]
  def change
    rename_table :Applications, :projects
    rename_column :projects, :ApplicationID, :id
    rename_column :projects, :ReserveID, :reserve_id
    rename_column :projects, :ApplicantID, :applicant_id
    rename_column :projects, :ProjectTitle, :title
    rename_column :projects, :ThesisTitle, :thesis_title
    rename_column :projects, :CourseName, :course_title
    rename_column :projects, :ProjectAbstract, :abstract
    rename_column :projects, :KeyWordSearch, :project_keywords
    rename_column :projects, :TaxonomicSearch, :taxonomic_keywords 
    rename_column :projects, :MethodDescription, :method_description 
    rename_column :projects, :MethodRemoveOrganisms, :method_remove_organisms
    rename_column :projects, :MethodTransferOrganisms, :method_transfer_organisms 
    rename_column :projects, :MethodStudyNonNativeSpecies, :method_study_non_native_species 
    rename_column :projects, :MethodChemicals, :method_chemicals 
    rename_column :projects, :MethodChemicalsList, :method_chemicals_list 
    rename_column :projects, :MethodSoilDisturbance, :method_soil_disturbance 
    rename_column :projects, :MethodLongTermStructures, :method_long_term_structures 
    rename_column :projects, :MethodStudyArea, :method_study_area 
    rename_column :projects, :ApplicationType, :project_type 
    rename_column :projects, :ApplicationStatus, :project_status 
    rename_column :projects, :ProjectStartDate, :start_date 
    rename_column :projects, :ProjectEndDate, :end_date 
    rename_column :projects, :PermitsMade, :permits_completed 
    rename_column :projects, :RecentPublications, :recent_publications 
    rename_column :projects, :MetaFData, :data_submitted
    rename_column :projects, :DisciplineOther, :discipline_other
    rename_column :projects, :DateSubmitted, :date_submitted

    add_column :projects, :discipline, :varchar
    add_column :projects, :course_number, :varchar
    add_column :projects, :approved_permits, :varchar
    add_column :projects, :involves_mammals, :tinyint
    add_column :projects, :involves_reptiles, :tinyint
    add_column :projects, :involves_amphibians, :tinyint
    add_column :projects, :involves_fish, :tinyint
    add_column :projects, :involves_birds, :tinyint
    add_column :projects, :involves_plants_fungus_soil, :tinyint
    add_column :projects, :involves_none, :tinyint

    rename_index :projects, :applicationid_reserveid, :project_id_reserve_id
    rename_index :projects, :ApplicationID, :project_id
    rename_index :projects, :ApplicationStatus, :project_status
    rename_index :projects, :ApplicationType, :project_type
    rename_index :projects, :CourseName, :project_course_name
    rename_index :projects, :DateSubmitted, :project_date_submitted
    rename_index :projects, :ProjectStart, :project_start_date
    rename_index :projects, :ReserveID, :reserve_id

    change_column_comment :projects, Discipline1:,  to: "DEPRICATED  Discipline of this application, if > 0 then discipline is found in the discipline table, if 0 then discipline is found in application table under column disciplineOther"
    change_column_comment :projects, MethodAnchorCollectShoreline:,  to: "DEPRICATED"
    change_column_comment :projects, NonNativeGenotype:,  to: "DEPRICATED"
    change_column_comment :projects, DateSubmitted:,  to: "DEPRICATED"
    change_column_comment :projects, app_html_type:,  to: "DEPRICATED"
    change_column_comment :projects, ProjectChanges:,  to: "DEPRICATED"
    change_column_comment :projects, ApplicationPassword:,  to: "DEPRICATED"
    change_column_comment :projects, USDACategories:,  to: "DEPRICATED"
    change_column_comment :projects, ApprovalStatus:,  to: "DEPRICATED"
    change_column_comment :projects, ApprovedBy:,  to: "DEPRICATED"
    change_column_comment :projects, ApprovalDate:,  to: "DEPRICATED"
    change_column_comment :projects, EMailType:,  to: "DEPRICATED"
    change_column_comment :projects, MissingData:,  to: "DEPRICATED"
    change_column_comment :projects, Page1Complete:,  to: "DEPRICATED"
    change_column_comment :projects, Page2Complete:,  to: "DEPRICATED"
    change_column_comment :projects, Page3Complete:,  to: "DEPRICATED"
    change_column_comment :projects, Page4Complete:,  to: "DEPRICATED"
    change_column_comment :projects, Page5Complete:,  to: "DEPRICATED"
    change_column_comment :projects, AnnualReportAccess:,  to: "DEPRICATED"
    change_column_comment :projects, ARPart1Access:,  to: "DEPRICATED"
    change_column_comment :projects, CommunicationLog:,  to: "DEPRICATED"
    change_column_comment :projects, AnnualReportAccessTEMP:,  to: "DEPRICATED"
    change_column_comment :projects, date_submitted:,  to: "Move data to submitted_at with default time"
    change_column_comment :projects, course_number:,  to: "You will find this info in the abstract field for a CLASS tupe project in RAM2 data"


    rename_column :AppAnswers, :ApplicationID, :project_id
    rename_column :AppPermits, :ApplicationID, :project_id
    rename_column :AppTeamMembers, :ApplicationID, :project_id
    rename_column :AppTeamMembers, :CanEditApplication, :can_edit_project
    rename_column :AppTeamMembers, :ViewedApplication, :viewed_project
    rename_column :Equipment, :ApplicationID, :project_id
    rename_column :Grants, :ApplicationID, :project_id
    rename_column :NRSPersonnel, :ReceiveApplicationEmail, :receive_project_email
    rename_column :ReservePermits, :ResearchApplication, :research_project  
    rename_column :ReservePermits, :ClassApplication, :class_project
    rename_column :ReservePermits, :PublicApplication, :public_project
    rename_column :ReservePermits, :HousingOnlyApplication, :housing_only_project
	rename_column :ReservePermits, :conference_application, :conference_project
	rename_column :ReserveQuestions, :ResearchApplication, :research_project  
    rename_column :ReserveQuestions, :ClassApplication, :class_project
    rename_column :ReserveQuestions, :PublicApplication, :public_project
    rename_column :ReserveQuestions, :HousingOnlyApplication, :housing_only_project
	rename_column :ReserveQuestions, :conference_application, :conference_project
	rename_column :applications_disciplines, :applications_disciplines_id, :id
	rename_column :applications_disciplines, :application_id, :project_id
	rename_column :logx, :application_id, :project_id

	rename_column :activities, :ApplicationID, :project_id
	or
	rename_column :visits, :ApplicationID, :project_id

    rename_index :ActAnswers, :Applications, :project
    rename_index :AppPermits, :Applications, :project
    rename_index :AppTeamMembers, :Applications, :project 
    rename_index :activities, :Application, :project
    rename_index :applications_disciplines, :applications_disciplines_id, :project_disciplines_id
    rename_index :logx, :index_logx_on_application_id, :index_logx_on_project_id
 
    ALTER TABLE `ReserveQuestions` MODIFY `QuestionLocation` ENUM('project','visit');
            
  end
end