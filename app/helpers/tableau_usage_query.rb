module TableauUsageQuery
  def tableau_usage(date_begin, date_end)
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

    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS user_count_raw#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS user_count_individuals#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS user_count_groups#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS user_days_raw#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS user_count_days_merged#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS results_table#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS nrs_reserves_table#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS results_table_transposed#{id};")


    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE user_count_raw#{id}
      SELECT
        visits.reserve_id AS reserve_id,
        user_visits.user_id AS user_id,
        user_visits.`role` AS role,
        projects.project_type,
        user_visits.`count` AS user_count,
        0 AS user_days
      FROM
        user_visits
        INNER JOIN visits ON user_visits.visit_id = visits.id
        INNER JOIN projects ON visits.project_id = projects.id
      WHERE
        user_visits.status = 'Approved'
        AND visits.status IN ('approved', 'in_review')
        AND projects.AnnualReportAccess = 1
        AND visits.report_access = 1
        AND user_visits.departs_at >= #{date_begin}
        AND user_visits.arrives_at <= #{date_end}
        AND visits.reserve_id < 100000;
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE user_count_individuals#{id}
      SELECT
        *
      FROM
        user_count_raw#{id}
      WHERE
        user_id != 1
      GROUP BY
        reserve_id,
        project_type,
        user_id,
        role,
        user_count,
        user_days;
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE user_count_groups#{id}
      SELECT
        *
      FROM
        user_count_raw#{id}
      WHERE
        user_id = 1;
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE user_days_raw#{id}
      SELECT
        visits.reserve_id AS reserve_id,
        user_visits.user_id AS user_id,
        user_visits.`role` AS role,
        projects.project_type,
        0 AS user_count,
        get_visit_days_in_period (
          user_visits.arrives_at,
          user_visits.departs_at,
          #{date_begin},
          #{date_end},
          `count`,
          actual_days
        ) AS user_days
        FROM
        user_visits
        INNER JOIN visits ON user_visits.visit_id = visits.id
        INNER JOIN projects ON visits.project_id = projects.id
      WHERE
        user_visits.status = 'Approved'
        AND visits.status IN ('approved', 'in_review')
        AND projects.AnnualReportAccess = 1
        AND visits.report_access = 1
        AND user_visits.departs_at >= #{date_begin}
        AND user_visits.arrives_at <= #{date_end}
        AND visits.reserve_id < 100000;
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE user_count_days_merged#{id}
      SELECT
        *
      FROM
        user_count_individuals#{id}
      UNION ALL
      SELECT
        *
      FROM
        user_count_groups#{id}
      UNION ALL
      SELECT
        *
      FROM
        user_days_raw#{id};
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE results_table#{id}
      SELECT
        reserve_id,
        IFNULL(project_type, 'TOTAL') AS project_type,
        SUM(user_count) AS CountAll,
        SUM(user_days) AS DaysAll
      FROM
        user_count_days_merged#{id}
      GROUP BY
        reserve_id,
        project_type;
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE nrs_reserves_table#{id}
      SELECT
        reserves.id AS reserve_id,
        reserves.`name` AS reserve_name,
        institutions.`name` AS reserve_campus
      FROM
        reserves
        LEFT JOIN institutions ON reserves.managing_campus_id = institutions.id
      WHERE
        reserves.id < 100000;
    end_sql

    ActiveRecord::Base.connection.exec_query(<<~end_sql)
      CREATE TEMPORARY TABLE results_table_transposed#{id}
      SELECT
        reserve_id,
        max(
          CASE project_type
            WHEN 'Research' THEN CountAll
          END
        ) AS ResearchUserCount,
        max(
          CASE project_type
            WHEN 'Class' THEN CountAll
          END
        ) AS ClassUserCount,
        max(
          CASE project_type
            WHEN 'Public Use' THEN CountAll
          END
        ) AS PublicUserCount,
        max(
          CASE project_type
            WHEN 'Housing' THEN CountAll
          END
        ) AS HousingUserCount,
        SUM(CountAll) AS CountAll,
        max(
          CASE project_type
            WHEN 'Research' THEN DaysAll
          END
        ) AS ResearchUCDays,
        max(
          CASE project_type
            WHEN 'Class' THEN DaysAll
          END
        ) AS ClassUCDays,
        max(
          CASE project_type
            WHEN 'Public Use' THEN DaysAll
          END
        ) AS PublicUCDays,
        max(
          CASE project_type
            WHEN 'Housing' THEN DaysAll
          END
        ) AS HousingUCDays,
        SUM(DaysAll) AS DaysAll
      FROM
        results_table#{id}
      GROUP BY
        reserve_id;
    end_sql

    data = ActiveRecord::Base.connection.exec_query(<<~end_sql)
      SELECT
        nrs_reserves_table#{id}.reserve_id,
        nrs_reserves_table#{id}.reserve_name,
        IF(nrs_reserves_table#{id}.reserve_id < 500, 0, 1) AS reserve_satellite,
        IFNULL(results_table_transposed#{id}.ResearchUserCount, 0) AS research_uc_user_count,
        IFNULL(results_table_transposed#{id}.ClassUserCount, 0) AS class_uc_user_count,
        IFNULL(results_table_transposed#{id}.PublicUserCount, 0) AS public_uc_user_count,
        IFNULL(results_table_transposed#{id}.HousingUserCount, 0) AS housing_uc_user_count,
        IFNULL(results_table_transposed#{id}.CountAll, 0) AS all_uc_user_count,
        IFNULL(results_table_transposed#{id}.ResearchUCDays, 0) AS research_uc_user_days,
        IFNULL(results_table_transposed#{id}.ClassUCDays, 0) AS class_uc_user_days,
        IFNULL(results_table_transposed#{id}.PublicUCDays, 0) AS public_uc_user_days,
        IFNULL(results_table_transposed#{id}.HousingUCDays, 0) AS housing_uc_user_days,
        IFNULL(results_table_transposed#{id}.DaysAll, 0) AS all_uc_user_days
      FROM
        nrs_reserves_table#{id}
        LEFT JOIN results_table_transposed#{id} ON nrs_reserves_table#{id}.reserve_id = results_table_transposed#{id}.reserve_id
      ORDER BY
        reserve_satellite,
        reserve_campus,
        reserve_name ASC;
    end_sql

    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS user_count_raw#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS user_count_individuals#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS user_count_groups#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS user_days_raw#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS user_count_days_merged#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS results_table#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS nrs_reserves_table#{id};")
    ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS results_table_transposed#{id};")

    return data
  end
end
