module ReportAffiliationQuery
  def affiliation(reserve: [], date_begin: nil, date_end: nil)

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

    sql_query = (<<~end_sql)
      SELECT
        user_visits.institution_id,
        institutions.*
      FROM
        user_visits
        INNER JOIN institutions ON user_visits.institution_id = institutions.id
        INNER JOIN visits ON user_visits.visit_id = visits.id
        INNER JOIN projects ON visits.project_id = projects.id
      WHERE
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
      GROUP BY
        user_visits.institution_id
      ORDER BY
        institutions.institution_type,
        institutions.`name`;
    end_sql

    return Institution.find_by_sql(sql_query)
  end
end
