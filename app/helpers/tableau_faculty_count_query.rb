module TableauFacultyCountQuery

  def tableau_faculty_count(date_begin: nil, date_end: nil)
    if defined?(request) && request&.session.present?
      id = ActiveRecord::Base.sanitize_sql(request.session[:session_id])
    else
      id = SecureRandom.hex
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

    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS faculty_campus_table#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS faculty_count_individuals_table#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS faculty_count_group_table#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS faculty_count_merged_table#{id};")

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE faculty_campus_table#{id}
      SELECT
        user_visits.user_id AS user_id,
        user_visits.`role` AS role,
        projects.project_type,
        visits.reserve_id AS reserve_id,
        fUserCountUCHome (institutions.institution_type, user_visits.`count`, institutions.managing_institution_id, 1) AS UCBerkeleyCount,
        fUserCountUCHome (institutions.institution_type, user_visits.`count`, institutions.managing_institution_id, 2) AS UCDavisCount,
        fUserCountUCHome (institutions.institution_type, user_visits.`count`, institutions.managing_institution_id, 3) AS UCIrvineCount,
        fUserCountUCHome (institutions.institution_type, user_visits.`count`, institutions.managing_institution_id, 4) AS UCLosAngelesCount,
        fUserCountUCHome (institutions.institution_type, user_visits.`count`, institutions.managing_institution_id, 5) AS UCMercedCount,
        fUserCountUCHome (institutions.institution_type, user_visits.`count`, institutions.managing_institution_id, 6) AS UCRiversideCount,
        fUserCountUCHome (institutions.institution_type, user_visits.`count`, institutions.managing_institution_id, 7) AS UCSanDiegoCount,
        fUserCountUCHome (institutions.institution_type, user_visits.`count`, institutions.managing_institution_id, 8) AS UCSanFranciscoCount,
        fUserCountUCHome (institutions.institution_type, user_visits.`count`, institutions.managing_institution_id, 9) AS UCSantaBarbaraCount,
        fUserCountUCHome (institutions.institution_type, user_visits.`count`, institutions.managing_institution_id, 10) AS UCSantaCruzCount,
        fUserCountUCHome (institutions.institution_type, user_visits.`count`, institutions.managing_institution_id, 11) AS UCUCOPCount,
        fUserCountCSU (institutions.institution_type, user_visits.`count`) AS CSUCount,
        fUserCountComCol (institutions.institution_type, user_visits.`count`) AS ComColCount,
        fUserCountOthCA (institutions.institution_type, user_visits.`count`) AS OthCACount,
        fUserCountOthUS (institutions.institution_type, user_visits.`count`) AS OthUSCount,
        fUserCountIntl (institutions.institution_type, user_visits.`count`) AS IntlCount,
        fUserCountK12 (institutions.institution_type, user_visits.`count`) AS K12Count,
        fUserCountNGO (institutions.institution_type, user_visits.`count`) AS NGOCount,
        fUserCountGov (institutions.institution_type, user_visits.`count`) AS GovCount,
        fUserCountBus (institutions.institution_type, user_visits.`count`) AS BusCount,
        fUserCountOthers (institutions.institution_type, user_visits.`count`) AS OthersCount
      FROM
        user_visits
        INNER JOIN institutions ON user_visits.institution_id = institutions.id
        INNER JOIN visits ON user_visits.visit_id = visits.id
        INNER JOIN projects ON visits.project_id = projects.id
      WHERE
        user_visits.status = 'Approved'
        AND visits.status IN ('Approved', 'Pending Approval')
        AND projects.AnnualReportAccess = 1
        AND visits.report_access = 1
        AND user_visits.departs_at >= #{date_begin}
        AND user_visits.arrives_at <= #{date_end}
        AND user_visits.`role` = 'Faculty'
        AND visits.reserve_id < 100000;
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE faculty_count_individuals_table#{id}
      SELECT
        *
      FROM
        faculty_campus_table#{id}
      WHERE
        user_id != 1
      GROUP BY
        user_id,
        reserve_id,
        project_type,
        role,
        UCBerkeleyCount,
        UCDavisCount,
        UCIrvineCount,
        UCLosAngelesCount,
        UCMercedCount,
        UCRiversideCount,
        UCSanDiegoCount,
        UCSanFranciscoCount,
        UCSantaBarbaraCount,
        UCSantaCruzCount,
        UCUCOPCount,
        CSUCount,
        ComColCount,
        OthCACount,
        OthUSCount,
        IntlCount,
        K12Count,
        NGOCount,
        GovCount,
        BusCount,
        OthersCount;
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE faculty_count_group_table#{id}
      SELECT
        *
      FROM
        faculty_campus_table#{id}
      WHERE
        user_id = 1;
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE faculty_count_merged_table#{id}
      SELECT
        *
      FROM
        faculty_count_individuals_table#{id}
      UNION ALL
      SELECT
        *
      FROM
        faculty_count_group_table#{id};
    end_sql

    data = ActiveRecord::Base.connection.exec_query(<<~end_sql)
      SELECT
        reserves.id,
        IF(reserves.id < 500, 0, 1) AS reserve_satellite,
        institutions.`Name` AS reserve_campus,
        reserves.`Name` AS reserve_name,
        IFNULL(SUM(UCBerkeleyCount), 0) AS CountUCBerkeley,
        IFNULL(SUM(UCDavisCount), 0) AS CountUCDavis,
        IFNULL(SUM(UCIrvineCount), 0) AS CountUCIrvine,
        IFNULL(SUM(UCLosAngelesCount), 0) AS CountUCLosAngeles,
        IFNULL(SUM(UCMercedCount), 0) AS CountUCMerced,
        IFNULL(SUM(UCRiversideCount), 0) AS CountUCRiverside,
        IFNULL(SUM(UCSanDiegoCount), 0) AS CountUCSanDiego,
        IFNULL(SUM(UCSanFranciscoCount), 0) AS CountUCSanFrancisco,
        IFNULL(SUM(UCSantaBarbaraCount), 0) AS CountUCSantaBarbara,
        IFNULL(SUM(UCSantaCruzCount), 0) AS CountUCSantaCruz,
        IFNULL(SUM(UCUCOPCount), 0) AS CountUCUCOP,
        IFNULL(SUM(CSUCount), 0) AS CountCSU,
        IFNULL(SUM(ComColCount), 0) AS CountComCol,
        IFNULL(SUM(OthCACount), 0) AS CountOthCA,
        IFNULL(SUM(OthUSCount), 0) AS CountOthUS,
        IFNULL(SUM(IntlCount), 0) AS CountIntl,
        IFNULL(SUM(K12Count), 0) AS CountK12,
        IFNULL(SUM(NGOCount), 0) AS CountNGO,
        IFNULL(SUM(GovCount), 0) AS CountGov,
        IFNULL(SUM(BusCount), 0) AS CountBus,
        IFNULL(SUM(OthersCount), 0) AS CountOthers
      FROM
        reserves
        LEFT JOIN faculty_count_merged_table#{id} ON reserves.id = faculty_count_merged_table#{id}.reserve_id
        LEFT JOIN institutions ON reserves.managing_campus_id = institutions.id
      WHERE
        reserves.id < 100000
      GROUP BY
        reserves.id
      ORDER BY
        reserve_satellite,
        reserve_campus,
        reserve_name ASC;
    end_sql

    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS faculty_campus_table#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS faculty_count_individuals_table#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS faculty_count_group_table#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS faculty_count_merged_table#{id};")

    return data
  end
end
