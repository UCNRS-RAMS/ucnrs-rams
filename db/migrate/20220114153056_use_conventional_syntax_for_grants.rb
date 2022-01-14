class UseConventionalSyntaxForGrants < ActiveRecord::Migration[6.1]
  def change
    rename_table :Grants, :fundings
    rename_column :fundings, :GrantID, :id
    rename_column :fundings, :Title, :title
    rename_column :fundings, :GrantNumber, :grant_number
    rename_column :fundings, :Sponsor, :sponsor_other
    rename_column :fundings, :PrincipalInvestigator, :principal_investigators
    rename_column :fundings, :CoPrincipalInvestigator, :co_principal_investigators
    rename_column :fundings, :StartDate, :start_date
    rename_column :fundings, :EndDate, :end_date
    reversible do |dir|
      dir.up do
        change_column_default :fundings, :end_date, nil
      end
      dir.down do
        change_column_default :fundings, :end_date, "1999-12-31"
      end
    end

    rename_column :fundings, :GrantDate, :grant_date
    rename_column :fundings, :AwardAmount, :award_amount
    rename_column :fundings, :GrantIsFunded, :is_funded
    rename_column :fundings, :GrantIsSelfFunded, :is_self_funded
    rename_column :fundings, :GrantIsSubmitted, :is_submitted
    rename_column :fundings, :GrantWillBeSubmitted, :will_be_submitted

    add_column :fundings, :was_denied, :boolean
    add_column :fundings, :funding_opportunity_number, :string
    add_column :fundings, :sponsor, "enum('National Science Foundation (NSF)','National Institute of Health (NIH)','U.S. Geological Survey (USGS)','U.S. Forest Service (USFS),U.S. Department of Agriculture (USDA)','California Department of Fish and Wildlife','Other')"

    change_column_comment :fundings, :funding_opportunity_number, from: nil, to: "Funding opportunity numbers (FON) is a number that a federal agency assigns to its grant announcement. FON are currently unique within the fundings.Gov System"
    change_column_comment :fundings, :is_funded, from: nil, to: "Project is currently being supported by at least one grant or contract"
    change_column_comment :fundings, :is_submitted, from: nil, to: "At least one grant or contract application has been submitted but has not yet been approved"
    change_column_comment :fundings, :will_be_submitted, from: nil, to: "At least one grant or contract application will be submitted in the future"
    change_column_comment :fundings, :was_denied,from: nil,  to: "Project grant or contract application was denied by the funding agency"
    change_column_comment :fundings, :is_self_funded, from: nil, to: "DEPRECATED"
    change_column_comment :fundings, :grant_date, from: nil, to: "DEPRECATED"

    change_column_null :fundings, :reserve_id, true

    reversible do |dir|
      dir.up do
        change_column_null :fundings, :reserve_id, true
      end
      dir.down do
        change_column_null :fundings, :reserve_id, false
      end
    end
  end
end
