class UseConventionalNamesForApplications < ActiveRecord::Migration[6.1]
  # rubocop:disable Metrics/MethodLength
  def change
    rename_table :Applications, :projects
    rename_column :projects, :ApplicationID, :id
    rename_column :projects, :ReserveID, :reserve_id
    rename_column :projects, :ApplicantID, :applicant_id
    rename_column :projects, :ProjectTitle, :title
    rename_column :projects, :ThesisTitle, :thesis_title
    rename_column :projects, :CourseName, :course_title
    rename_column :projects, :ProjectAbstract, :abstract
    rename_column :projects, :KeyWordSearch, :keywords
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
    rename_column :projects, :ApplicationStatus, :status
    reversible do |dir|
      dir.up do
        execute("ALTER TABLE projects MODIFY COLUMN status ENUM('Closed','Open','Rejected','Cancelled','Updating','Temp','All','Incomplete')")
        execute("UPDATE projects SET status = 'Incomplete' WHERE status = 'Updating' OR status = 'Temp'")
        execute("UPDATE projects SET status = 'Closed' WHERE status = 'Rejected' OR status = 'Cancelled'")
        execute("ALTER TABLE projects MODIFY COLUMN status ENUM('Closed','Open','Incomplete')")
      end

      dir.down do
        execute("ALTER TABLE projects MODIFY COLUMN status ENUM('Closed','Open','Rejected','Cancelled','Updating','Temp','All','Incomplete')")
        execute("UPDATE projects SET status = 'Temp' WHERE status = 'Incomplete'")
        execute("ALTER TABLE projects MODIFY COLUMN status ENUM('Closed','Open','Rejected','Cancelled','Updating','Temp','All')")
      end
    end
    rename_column :projects, :ProjectStartDate, :start_date 
    rename_column :projects, :ProjectEndDate, :end_date 
    rename_column :projects, :PermitsMade, :permits_completed 
    rename_column :projects, :RecentPublications, :recent_publications 
    rename_column :projects, :MetaFData, :data_submitted
    rename_column :projects, :DisciplineOther, :discipline_other
    rename_column :projects, :DateSubmitted, :date_submitted

    add_column :projects, :discipline, :string
    add_column :projects, :course_number, :string
    add_column :projects, :approved_permits, :string
    add_column :projects, :involves_mammals, :boolean
    add_column :projects, :involves_reptiles, :boolean
    add_column :projects, :involves_amphibians, :boolean
    add_column :projects, :involves_fish, :boolean
    add_column :projects, :involves_birds, :boolean
    add_column :projects, :involves_plants_fungus_soil, :boolean
    add_column :projects, :involves_none, :boolean

    rename_index :projects, :ApplicationID, :project_id
    rename_index :projects, :ApplicationStatus, :project_status
    rename_index :projects, :ApplicationType, :project_type
    rename_index :projects, :CourseName, :project_course_name
    rename_index :projects, :DateSubmitted, :project_date_submitted
    rename_index :projects, :ProjectStart, :project_start_date

    change_column_comment :projects, :Discipline1,
      from: "Discipline of this application, if > 0 then discipline is found in the discipline table, if 0 then discipline is found in application table under column disciplineOther",
      to: "DEPRECATED Discipline of this application, if > 0 then discipline is found in the discipline table, if 0 then discipline is found in application table under column disciplineOther"
    change_column_comment :projects, :MethodAnchorCollectShoreline, from: "Boolean", to: "DEPRECATED"
    change_column_comment :projects, :NonNativeGenotype, from: "Boolean", to: "DEPRECATED"
    change_column_comment :projects, :date_submitted, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :app_html_type, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :ProjectChanges, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :ApplicationPassword, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :USDACategories, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :ApprovalStatus, from: "Pending or Approved", to: "DEPRECATED"
    change_column_comment :projects, :ApprovedBy, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :ApprovalDate, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :EMailType, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :MissingData, from: nil,  to: "DEPRECATED"
    change_column_comment :projects, :Page1Complete, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :Page2Complete, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :Page3Complete, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :Page4Complete, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :Page5Complete, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :AnnualReportAccess, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :ARPart1Access, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :CommunicationLog, from: "Log of activity and notes made by administrator", to: "DEPRECATED"
    change_column_comment :projects, :AnnualReportAccessTEMP, from: nil, to: "DEPRECATED"
    change_column_comment :projects, :date_submitted, from: "DEPRECATED", to: "Move data to submitted_at with default time"
    change_column_comment :projects, :course_number, from: nil, to: "You will find this info in the abstract field for a CLASS type project in RAM2 data"

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

    rename_index :applications_disciplines, :applications_disciplines_id, :project_disciplines_id

    reversible do |dir|
      dir.up do
        execute("ALTER TABLE ReserveQuestions MODIFY COLUMN QuestionLocation ENUM('Application','Reservation','project')")
        execute("UPDATE ReserveQuestions SET QuestionLocation = 'project' WHERE QuestionLocation = 'Application'")
        execute("ALTER TABLE ReserveQuestions MODIFY COLUMN QuestionLocation ENUM('Reservation','project')")
      end

      dir.down do
        execute("ALTER TABLE ReserveQuestions MODIFY COLUMN QuestionLocation ENUM('Reservation','project','Application')")
        execute("UPDATE ReserveQuestions SET QuestionLocation = 'Application' WHERE QuestionLocation = 'project'")
        execute("ALTER TABLE ReserveQuestions MODIFY COLUMN QuestionLocation ENUM('Reservation','Application')")
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
