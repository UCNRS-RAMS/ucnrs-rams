class ProjectPermitAnswer < ApplicationRecord
  belongs_to :project
  belongs_to :permit

  validates :answer, inclusion: [true, false]

  def self.for_project(project)
    if project.present?
      where(project_id: project)
    else
      all
    end
  end

  def self.for_answer(answer)
    if answer.present?
      where(answer: answer)
    else
      all
    end
  end

  def self.with_permits_authority_column
    select("project_permit_answers.*, permits.authority")
      .left_joins(:permit)
  end

  def self.replace_all(project_permit_answers)
    if !project_permit_answers.blank?
      rows = project_permit_answers.map do |answer|
        ActiveRecord::Base.sanitize_sql([
          "(?,?,?,NOW(),NOW())",
          answer.project_id,
          answer.permit_id,
          answer.answer
        ])
      end

      connection.execute(<<~end_sql)
      INSERT INTO #{table_name} (
        #{arel_table[:project_id].name},
        #{arel_table[:permit_id].name},
        #{arel_table[:answer].name},
        #{arel_table[:created_at].name},
        #{arel_table[:updated_at].name})
      VALUES
        #{rows.join(",\n  ")}
      AS new
      ON DUPLICATE KEY UPDATE
        answer = new.answer,
        updated_at = new.updated_at
      end_sql
    end
  end

  def self.of_iacuc_type
    left_joins(:permit)
      .merge(Permit.of_iacuc_type)
  end
end
