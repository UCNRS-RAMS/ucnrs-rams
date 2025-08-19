module ProjectFundingQuery
  def project_funding(reserve: nil, begin_date: nil, end_date: nil)

    if reserve.present?
      reserve_query = "visits.reserve_id = #{reserve}"
    else
      reserve_query = "visits.reserve_id = NULL"
    end

    Funding
      .select("fundings.*, visits.reserve_id")
      .left_outer_joins(project: [visits: :user_visits])
      .where(
        "#{reserve_query}
        AND user_visits.arrives_at >= :start_date
        AND user_visits.departs_at <= :stop_date
        AND user_visits.status = 'Approved'
        AND projects.project_type = 'Research'
        AND projects.AnnualReportAccess = 1
        AND projects.status IN ('Open', 'Closed')",
        { start_date: begin_date, stop_date: end_date },
      )
      .includes(:project)
      .group(:id)
      .order("visits.reserve_id")
  end
end
