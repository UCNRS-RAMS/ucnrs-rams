module ReportQueries
  def query_part_1(reserve, begin_date, end_date)
    if defined?(request) && request&.session.present?
      id = ActiveRecord::Base.sanitize_sql(request.session[:session_id])
    else
      id = SecureRandom.hex
    end

    begin_date  = ActiveRecord::Base.sanitize_sql("#{begin_date} 00:00:00")
    end_date    = ActiveRecord::Base.sanitize_sql("#{end_date} 23:59:59")

    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS temptableuserscount#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS tempusercounttable1#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS tempusercounttable2#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS temptableusersdays#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS MergedTables1#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS ResultsTable#{id};")

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE
        temptableuserscount#{id}
      SELECT
        user_visits.user_id                     AS user_id,
        user_visits.role                        AS role,
        projects.project_type,
        fUserCountUCHome(
          institutions.institution_type,
          user_visits.count,
          institutions.managing_institution_id,
          #{reserve.managing_campus.id}
        )                                       AS UCHomeCount,
        fUserCountUCAway(
          institutions.institution_type,
          user_visits.count,
          institutions.managing_institution_id,
          #{reserve.managing_campus.id}
        )                                       AS UCAwayCount,
        fUserCountCSU(
          institutions.institution_type,
          user_visits.count
        )                                       AS CSUCount,
        fUserCountComCol(
          institutions.institution_type,
          user_visits.count
        )                                       AS ComColCount,
        fUserCountOthCA(
          institutions.institution_type,
          user_visits.count
        )                                       AS OthCACount,
        fUserCountOthUS(
          institutions.institution_type,
          user_visits.count
        )                                       AS OthUSCount,
        fUserCountIntl(
          institutions.institution_type,
          user_visits.count
        )                                       AS IntlCount,
        fUserCountK12(
          institutions.institution_type,
          user_visits.count
        )                                       AS K12Count,
        fUserCountNGO(
          institutions.institution_type,
          user_visits.count
        )                                       AS NGOCount,
        fUserCountGov(
          institutions.institution_type,
          user_visits.count
        )                                       AS GovCount,
        fUserCountBus(
          institutions.institution_type,
          user_visits.count
        )                                       AS BusCount,
        fUserCountOthers(
          institutions.institution_type,
          user_visits.count
        )                                       AS OthersCount,
        user_visits.count                       AS Count,
        0                                       AS UCHomeDays,
        0                                       AS UCAwayDays,
        0                                       AS CSUDays,
        0                                       AS ComColDays,
        0                                       AS OthCADays,
        0                                       AS OthUSDays,
        0                                       AS IntlDays,
        0                                       AS K12Days,
        0                                       AS NGODays,
        0                                       AS GovDays,
        0                                       AS BusDays,
        0                                       AS OtherDays,
        0                                       AS All1
      FROM
        user_visits
        INNER JOIN institutions   ON user_visits.institution_id = institutions.id
        INNER JOIN visits         ON user_visits.visit_id       = visits.id
        INNER JOIN projects       ON visits.project_id          = projects.id
      WHERE
        user_visits.`status`        = 'Approved'
        AND (
          visits.`status`           = 'approved'
          OR visits.`status`        = 'in_review'
        )
        AND visits.report_access    = 1
        AND user_visits.departs_at  >= '#{begin_date}'
        AND user_visits.arrives_at  <= '#{end_date}'
        AND visits.reserve_id       = #{reserve.id};
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE
        tempusercounttable1#{id}
      SELECT
        *
      FROM
        temptableuserscount#{id}
      WHERE
        user_id != 1
      GROUP BY
        project_type,
        user_id,
        role,
        UCHomeCount, UCAwayCount, CSUCount, ComColCount, OthCACount, OthUSCount, IntlCount, K12Count, NGOCount, GovCount, BusCount, OthersCount, Count,
        UCHomeDays, UCAwayDays, CSUDays, ComColDays, OthCADays, OthUSDays, IntlDays, K12Days, NGODays, GovDays, BusDays, OtherDays, All1 ;
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE
        tempusercounttable2#{id}
      SELECT
        *
      FROM
        temptableuserscount#{id}
      WHERE
        user_id = 1
      ORDER BY
        project_type ASC,
        user_id ASC,
        role ASC;
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE
        temptableusersdays#{id}
      SELECT
        user_visits.user_id                     AS user_id,
        user_visits.role                        AS role,
        projects.project_type,
        0                                       AS UCHomeCount,
        0                                       AS UCAwayCount,
        0                                       AS CSUCount,
        0                                       AS ComColCount,
        0                                       AS OthCACount,
        0                                       AS OthUSCount,
        0                                       AS IntlCount,
        0                                       AS K12Count,
        0                                       AS NGOCount,
        0                                       AS GovCount,
        0                                       AS BusCount,
        0                                       AS OthersCount,
        0                                       AS Count,
        fUserDaysUCHome(
          institutions.institution_type,
          get_visit_days_in_period(
            user_visits.arrives_at,
            user_visits.departs_at,
            '#{begin_date}',
            '#{end_date}',
            user_visits.count,
            user_visits.actual_days
          ),
          institutions.managing_institution_id,
          #{reserve.managing_campus.id}
        )                                        AS UCHomeDays,
        fUserDaysUCAway(
          institutions.institution_type,
          get_visit_days_in_period(
            user_visits.arrives_at,
            user_visits.departs_at,
            '#{begin_date}',
            '#{end_date}',
            user_visits.count,
            user_visits.actual_days
          ),
          institutions.managing_institution_id,
          #{reserve.managing_campus.id}
        )                                        AS UCAwayDays,
        fUserDaysCSU(
          institutions.institution_type,
          get_visit_days_in_period(
            user_visits.arrives_at,
            user_visits.departs_at,
            '#{begin_date}',
            '#{end_date}',
            user_visits.count,
            user_visits.actual_days
          )
        )                                        AS CSUDays,
        fUserDaysComCol(
          institutions.institution_type,
          get_visit_days_in_period(
            user_visits.arrives_at,
            user_visits.departs_at,
            '#{begin_date}',
            '#{end_date}',
            user_visits.count,
            user_visits.actual_days
          )
        )                                        AS ComColDays,
        fUserDaysOthCA(
          institutions.institution_type,
          get_visit_days_in_period(
            user_visits.arrives_at,
            user_visits.departs_at,
            '#{begin_date}',
            '#{end_date}',
            user_visits.count,
            user_visits.actual_days
          )
        )                                        AS OthCADays,
        fUserDaysOthUS(
          institutions.institution_type,
          get_visit_days_in_period(
            user_visits.arrives_at,
            user_visits.departs_at,
            '#{begin_date}',
            '#{end_date}',
            user_visits.count,
            user_visits.actual_days
          )
        )                                        AS OthUSDays,
        fUserDaysIntl(
          institutions.institution_type,
          get_visit_days_in_period(
            user_visits.arrives_at,
            user_visits.departs_at,
            '#{begin_date}',
            '#{end_date}',
            user_visits.count,
            user_visits.actual_days
          )
        )                                        AS IntlDays,
        fUserDaysK12(
          institutions.institution_type,
          get_visit_days_in_period(
            user_visits.arrives_at,
            user_visits.departs_at,
            '#{begin_date}',
            '#{end_date}',
            user_visits.count,
            user_visits.actual_days
          )
        )                                        AS K12Days,
        fUserDaysNGO(
          institutions.institution_type,
          get_visit_days_in_period(
            user_visits.arrives_at,
            user_visits.departs_at,
            '#{begin_date}',
            '#{end_date}',
            user_visits.count,
            user_visits.actual_days
          )
        )                                        AS NGODays,
        fUserDaysGov(
          institutions.institution_type,
          get_visit_days_in_period(
            user_visits.arrives_at,
            user_visits.departs_at,
            '#{begin_date}',
            '#{end_date}',
            user_visits.count,
            user_visits.actual_days
          )
        )                                        AS GovDays,
        fUserDaysBus(
          institutions.institution_type,
          get_visit_days_in_period(
            user_visits.arrives_at,
            user_visits.departs_at,
            '#{begin_date}',
            '#{end_date}',
            user_visits.count,
            user_visits.actual_days
          )
        )                                        AS BusDays,
        fUserDaysOther(
          institutions.institution_type,
          get_visit_days_in_period(
            user_visits.arrives_at,
            user_visits.departs_at,
            '#{begin_date}',
            '#{end_date}',
            user_visits.count,
            user_visits.actual_days
          )
        )                                        AS OtherDays,
        get_visit_days_in_period(
          user_visits.arrives_at,
          user_visits.departs_at,
          '#{begin_date}',
          '#{end_date}',
          user_visits.count,
          user_visits.actual_days
        )                                        AS All1
      FROM
        user_visits
        INNER JOIN institutions   ON user_visits.institution_id = institutions.id
        INNER JOIN visits         ON user_visits.visit_id       = visits.id
        INNER JOIN projects       ON visits.project_id          = projects.id
      WHERE
        user_visits.`status`        = 'Approved'
        AND (
          visits.`status`           = 'approved'
          OR visits.`status`        = 'in_review'
        )
        AND visits.report_access    = 1
        AND user_visits.departs_at  >= '#{begin_date}'
        AND user_visits.arrives_at  <= '#{end_date}'
        AND visits.reserve_id       = #{reserve.id};
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE
        MergedTables1#{id}
      SELECT * FROM tempusercounttable1#{id}
      UNION ALL SELECT * FROM tempusercounttable2#{id}
      UNION ALL SELECT * FROM temptableusersdays#{id};
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE
        ResultsTable#{id} AS
          SELECT
            IFNULL(project_type,'TOTAL' )      AS project_type,
            IFNULL(role,'SUBTOTAL' )           AS role,
            SUM(UCHomeCount)                   AS CountUCHome,
            SUM(UCHomeDays)                    AS DaysUCHome,
            SUM(UCAwayCount)                   AS CountUCAway,
            SUM(UCAwayDays)                    AS DaysUCAway,
            SUM(CSUCount)                      AS CountCSU,
            SUM(CSUDays)                       AS DaysCSU,
            SUM(ComColCount)                   AS CountComCol,
            SUM(ComColDays)                    AS DaysComCol,
            SUM(OthCACount)                    AS CountOthCA,
            SUM(OthCADays)                     AS DaysOthCA,
            SUM(OthUSCount)                    AS CountOthUS,
            SUM(OthUSDays)                     AS DaysOthUS,
            SUM(IntlCount)                     AS CountIntl,
            SUM(IntlDays)                      AS DaysIntl,
            SUM(K12Count)                      AS CountK12,
            SUM(K12Days)                       AS DaysK12,
            SUM(NGOCount)                      AS CountNGO,
            SUM(NGODays)                       AS DaysNGO,
            SUM(GovCount)                      AS CountGov,
            SUM(GovDays)                       AS DaysGov,
            SUM(BusCount)                      AS CountBus,
            SUM(BusDays)                       AS DaysBus,
            SUM(OthersCount)                   AS CountOthers,
            SUM(OtherDays)                     AS DaysOther,
            SUM(Count)                         AS CountAll,
            SUM(All1)                          AS DaysAll
          FROM
            MergedTables1#{id}
          GROUP BY
            project_type,
            role                               WITH ROLLUP;
    end_sql

    part_1_data = ActiveRecord::Base.connection.exec_query(<<~end_sql)
      SELECT
        *
      FROM
        ResultsTable#{id}
      ORDER BY
        FIELD(
          project_type,
          'Research',
          'Class',
          'Public Use',
          'Housing',

          'TOTAL'
        ),

        FIELD(
          role,
          '',
          'No selection',
          'Research Faculty',
          'Faculty',
          'Research Scientist',
          'Research Scientist/Post Doc',
          'Research Assistant',
          'Research Assistant - Non Academic',
          'Research Assistant (non-student/faculty/postdoc)',
          'Graduate Student',
          'Graduate Student Researcher',
          'Undergraduate Student Researcher',
          'Undergraduate Student',
          'College Class Instructor',
          'College Class Student',
          'College Class Graduate Student',
          'College Class Undergraduate Student',
          'K-12 Instructor',
          'K-12 Student',
          'Arts or Humanities',
          'Arts or Humanities - Non Academic',
          'Arts/Humanities (non-student/faculty/postdoc)' ,
          'Professional',
          'Other',
          'Docent',
          'Volunteer',
          'Staff',

          'SUBTOTAL'
        ),

        role;
    end_sql

    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS temptableuserscount#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS tempusercounttable1#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS tempusercounttable2#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS temptableusersdays#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS MergedTables1#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS ResultsTable#{id};")

    return part_1_data
  end

  def query_part_2()

  end
end
