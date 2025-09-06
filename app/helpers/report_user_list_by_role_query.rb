module ReportUserListByRoleQuery
  def user_list_by_role(reserve: [], date_begin: nil, date_end: nil)

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

    UserVisit
      .select("user_visits.user_id, user_visits.role, user_visits.institution_id")
      .left_outer_joins(visit: :project)
      .where(
        (<<~end_sql)
          visits.reserve_id IN (
            SELECT CAST(j.id AS UNSIGNED) AS user_id
            FROM JSON_TABLE(
                CONCAT('["', REPLACE(#{reserve}, ',', '","'), '"]'),
                '$[*]' COLUMNS (id VARCHAR(20) PATH '$')
            ) AS j
          )
          AND user_visits.departs_at >= #{date_begin}
          AND user_visits.arrives_at <= #{date_end}
          AND user_visits.status = 'Approved'
          AND projects.AnnualReportAccess = 1
          AND visits.report_access = 1
          AND user_visits.user_id != 1
        end_sql
      )
      .group(:user_id, :role, :institution_id)
      .order(role: "ASC")
  end
end
