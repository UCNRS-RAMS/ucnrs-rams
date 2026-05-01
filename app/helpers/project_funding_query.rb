module ProjectFundingQuery
  def project_funding(reserve: nil, date_begin: nil, date_end: nil)
    return Funding.none if reserve.blank? || date_begin.blank? || date_end.blank?

    Funding
      .select("fundings.*, visits.reserve_id")
      .left_outer_joins(project: [visits: :user_visits])
      .merge(Visit.by_reserve(reserve))
      .where("user_visits.departs_at >= ?", "#{date_begin} 00:00:00")
      .where("user_visits.arrives_at <= ?", "#{date_end} 23:59:59")
      .merge(UserVisit.approved_status)
      .merge(Project.project_type_research.where(status: [:open, :closed]))
      .where("projects.AnnualReportAccess = 1")
      .includes(:project)
      .group(:id)
      .order("visits.reserve_id")
  end
end
