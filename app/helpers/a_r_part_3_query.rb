module ARPart3Query
  def a_r_part_3(reserve: [], date_begin: nil, date_end: nil)
    if reserve.present?
      reserve = reserve.to_s
    else
      reserve = "NULL"
    end

    if date_begin.present?
      date_begin = ActiveRecord::Base.sanitize_sql("'#{date_begin} 00:00:00'")
    else
      date_begin = "NULL"
    end

    if date_end.present?
      date_end = ActiveRecord::Base.sanitize_sql("'#{date_end} 23:59:59'")
    else
      date_end = "NULL"
    end

    project_scope = Project
      .select("projects.*, institutions.institution_type, institutions.name AS institution_name")
      .of_type("class")
      .joins(:visits, owner: :institution)
      .merge(
        Visit
          .with_report_access(true)
          .where(<<~end_sql)
            visits.reserve_id IN (
              SELECT CAST(j.id AS UNSIGNED) AS user_id
              FROM JSON_TABLE(
                  CONCAT('["', REPLACE(#{reserve}, ',', '","'), '"]'),
                  '$[*]' COLUMNS (id VARCHAR(20) PATH '$')
              ) AS j
            )
          end_sql
          .joins(:user_visits)
          .merge(
            UserVisit
              .having_between_time(date_start: date_begin, date_end: date_end)
              .where(status: :approved),
          )
      )
      .group(:id)
      .order(
        Institution.arel_table[:institution_type],
        Institution.arel_table[:name],
        Project.arel_table[:course_title],
      )
      .includes([:owner])

    project_scope
      .map { |project| ProjectPresenter.new(project: project) }
      .group_by(&:institution_type)
      .each_with_object({}) do |(institution_type, projects), hash|
        hash[institution_type] = projects.group_by(&:institution_name)
      end
  end
end
