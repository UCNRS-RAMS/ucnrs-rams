module ProjectFundingQuery
  def project_funding(reserve: nil, date_begin: nil, date_end: nil)

    if reserve.present?
      reserve_query = "visits.reserve_id = #{reserve}"
    else
      reserve_query = "visits.reserve_id = NULL"
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

    Funding
      .select("fundings.*, visits.reserve_id")
      .left_outer_joins(project: [visits: :user_visits])
      .where(
        "#{reserve_query}
        AND user_visits.departs_at >= #{date_begin}
        AND user_visits.arrives_at <= #{date_end}
        AND user_visits.status = 'Approved'
        AND projects.project_type = 'Research'
        AND projects.AnnualReportAccess = 1
        AND projects.status IN ('Open', 'Closed')",
      )
      .includes(:project)
      .group(:id)
      .order("visits.reserve_id")
  end
end
