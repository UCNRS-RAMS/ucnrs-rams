# rubocop:disable Metrics/ClassLength

class Reports::ARPart1Query
  AR_PART_1_TEMP_TABLES = %w[
    temptableuserscount
    tempusercounttable1
    tempusercounttable2
    temptableusersdays
    MergedTables1
    ResultsTable
  ].freeze

  def self.for_reserve(reserve, date_begin: nil, date_end: nil)
    return if reserve.blank?

    new(
      visits: Visit.where(reserve_id: reserve.id),
      managing_campus_id: reserve.managing_campus_id,
      date_begin: date_begin,
      date_end: date_end,
    ).call
  end

  def self.for_campus(campus_id, date_begin: nil, date_end: nil)
    return if campus_id.blank?

    new(
      visits: Visit.joins(:reserve).where(reserves: { managing_campus_id: campus_id }),
      managing_campus_id: campus_id,
      date_begin: date_begin,
      date_end: date_end,
    ).call
  end

  def self.for_visit(visit, date_begin: nil, date_end: nil)
    return if visit.blank?

    new(
      visits: Visit.where(id: visit.id),
      managing_campus_id: visit.reserve.managing_campus_id,
      date_begin: date_begin,
      date_end: date_end,
    ).call
  end

  def initialize(visits:, managing_campus_id:, date_begin: nil, date_end: nil)
    @visits = visits
    @managing_campus_id = managing_campus_id
    @date_begin = date_begin
    @date_end = date_end
  end

  # Report ---------------------------------------------------------------------

  def call
    return if visits.nil? || date_begin.blank? || date_end.blank?

    campus_id = managing_campus_id.to_i

    quoted_date_begin = ActiveRecord::Base.connection.quote("#{date_begin} 00:00:00")
    quoted_date_end = ActiveRecord::Base.connection.quote("#{date_end} 23:59:59")

    reserve_zone = ActiveRecord::Base.connection.quote("US/Pacific")

    source = source_sql(date_begin: quoted_date_begin, date_end: quoted_date_end)

    begin
      drop_temp_tables

      ActiveRecord::Base.connection.exec_query(<<~end_sql)
        CREATE TEMPORARY TABLE
          temptableuserscount
        SELECT
          user_visits.user_id                                                                     AS user_id,
          user_visits.role                                                                        AS role,
          projects.project_type,
          visits.reserve_id                                                                       AS reserve_id,
          IF(institutions.institution_type = 'University of California'
               AND institutions.managing_institution_id <=> #{campus_id},
             user_visits.count, 0)                                                                AS UCHomeCount,
          IF(institutions.institution_type = 'University of California'
               AND NOT (institutions.managing_institution_id <=> #{campus_id}),
             user_visits.count, 0)                                                                AS UCAwayCount,
          IF(institutions.institution_type = 'California State University System',
             user_visits.count, 0)                                                                AS CSUCount,
          IF(institutions.institution_type = 'California Community College',
             user_visits.count, 0)                                                                AS ComColCount,
          IF(institutions.institution_type = 'California - Other University or College',
             user_visits.count, 0)                                                                AS OthCACount,
          IF(institutions.institution_type = 'U.S. - University or College Outside of California',
             user_visits.count, 0)                                                                AS OthUSCount,
          IF(institutions.institution_type = 'International University or College',
             user_visits.count, 0)                                                                AS IntlCount,
          IF(institutions.institution_type = 'K-12 Education',
             user_visits.count, 0)                                                                AS K12Count,
          IF(institutions.institution_type = 'Non-Governmental Organization or Non-Profit Entity',
             user_visits.count, 0)                                                                AS NGOCount,
          IF(institutions.institution_type = 'Governmental Agency or Entity',
             user_visits.count, 0)                                                                AS GovCount,
          IF(institutions.institution_type = 'Business Entity',
             user_visits.count, 0)                                                                AS BusCount,
          IF(institutions.institution_type = 'Individual or Other Entity',
             user_visits.count, 0)                                                                AS OthersCount,
          user_visits.count                                                                       AS Count,
          0                                                                                       AS UCHomeDays,
          0                                                                                       AS UCAwayDays,
          0                                                                                       AS CSUDays,
          0                                                                                       AS ComColDays,
          0                                                                                       AS OthCADays,
          0                                                                                       AS OthUSDays,
          0                                                                                       AS IntlDays,
          0                                                                                       AS K12Days,
          0                                                                                       AS NGODays,
          0                                                                                       AS GovDays,
          0                                                                                       AS BusDays,
          0                                                                                       AS OtherDays,
          0                                                                                       AS All1
        #{source};
      end_sql

      ActiveRecord::Base.connection.exec_query(<<~end_sql)
        CREATE TEMPORARY TABLE
          tempusercounttable1
        SELECT
          *
        FROM
          temptableuserscount
        WHERE
          user_id != 1
        GROUP BY
          project_type,
          reserve_id,
          user_id,
          role,
          UCHomeCount, UCAwayCount, CSUCount, ComColCount, OthCACount, OthUSCount, IntlCount, K12Count, NGOCount, GovCount, BusCount, OthersCount, Count,
          UCHomeDays, UCAwayDays, CSUDays, ComColDays, OthCADays, OthUSDays, IntlDays, K12Days, NGODays, GovDays, BusDays, OtherDays, All1 ;
      end_sql

      ActiveRecord::Base.connection.exec_query(<<~end_sql)
        CREATE TEMPORARY TABLE
          tempusercounttable2
        SELECT
          *
        FROM
          temptableuserscount
        WHERE
          user_id = 1
        ORDER BY
          project_type ASC,
          user_id ASC,
          role ASC;
      end_sql

      ActiveRecord::Base.connection.exec_query(<<~end_sql)
        CREATE TEMPORARY TABLE
          temptableusersdays
        SELECT
          user_id,
          role,
          project_type,
          0                                                           AS reserve_id,
          0                                                           AS UCHomeCount,
          0                                                           AS UCAwayCount,
          0                                                           AS CSUCount,
          0                                                           AS ComColCount,
          0                                                           AS OthCACount,
          0                                                           AS OthUSCount,
          0                                                           AS IntlCount,
          0                                                           AS K12Count,
          0                                                           AS NGOCount,
          0                                                           AS GovCount,
          0                                                           AS BusCount,
          0                                                           AS OthersCount,
          0                                                           AS Count,
          fUserDaysUCHome(institution_type, visit_days,
            managing_institution_id, #{campus_id})                    AS UCHomeDays,
          fUserDaysUCAway(institution_type, visit_days,
            managing_institution_id, #{campus_id})                    AS UCAwayDays,
          fUserDaysCSU(institution_type, visit_days)                  AS CSUDays,
          fUserDaysComCol(institution_type, visit_days)               AS ComColDays,
          fUserDaysOthCA(institution_type, visit_days)                AS OthCADays,
          fUserDaysOthUS(institution_type, visit_days)                AS OthUSDays,
          fUserDaysIntl(institution_type, visit_days)                 AS IntlDays,
          fUserDaysK12(institution_type, visit_days)                  AS K12Days,
          fUserDaysNGO(institution_type, visit_days)                  AS NGODays,
          fUserDaysGov(institution_type, visit_days)                  AS GovDays,
          fUserDaysBus(institution_type, visit_days)                  AS BusDays,
          fUserDaysOther(institution_type, visit_days)                AS OtherDays,
          visit_days                                                  AS All1
        FROM (
          SELECT
            *,
            CAST(
              IF(actual_days > 0,
                 ABS(CEILING(CAST(uv_count AS FLOAT) * CAST(actual_days AS FLOAT) * period_days / visit_total_days)),
                 ABS(CEILING(CAST(uv_count AS FLOAT) * period_days)))
              AS SIGNED)                          AS visit_days
          FROM (
            SELECT
              *,
              DATEDIFF(visit_end_local, visit_beg_local) + 1                                    AS visit_total_days,
              DATEDIFF(
                IF(DATEDIFF(visit_end_local, #{quoted_date_end}) < 0, visit_end_local, #{quoted_date_end}),
                IF(DATEDIFF(visit_beg_local, #{quoted_date_begin}) < 0, #{quoted_date_begin}, visit_beg_local)
              ) + 1                                                                             AS period_days
            FROM (
              SELECT
                user_visits.user_id                                                             AS user_id,
                user_visits.role                                                                AS role,
                projects.project_type                                                           AS project_type,
                institutions.institution_type                                                   AS institution_type,
                institutions.managing_institution_id                                            AS managing_institution_id,
                user_visits.count                                                               AS uv_count,
                user_visits.actual_days                                                         AS actual_days,
                CONVERT_TZ(user_visits.arrives_at, 'UTC', #{reserve_zone})                      AS visit_beg_local,
                CONVERT_TZ(user_visits.departs_at, 'UTC', #{reserve_zone})                      AS visit_end_local
              #{source}
            ) AS visits_local
          ) AS visits_spans
        ) AS visits_days;
      end_sql

      ActiveRecord::Base.connection.exec_query(<<~end_sql)
        CREATE TEMPORARY TABLE
          MergedTables1
        SELECT * FROM tempusercounttable1
        UNION ALL SELECT * FROM tempusercounttable2
        UNION ALL SELECT * FROM temptableusersdays;
      end_sql

      ActiveRecord::Base.connection.exec_query(<<~end_sql)
        CREATE TEMPORARY TABLE
          ResultsTable AS
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
              MergedTables1
            GROUP BY
              project_type,
              role                               WITH ROLLUP;
      end_sql

      part_1_data = ActiveRecord::Base.connection.exec_query(<<~end_sql)
        SELECT
          *
        FROM
          ResultsTable
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

      part_1_data
    ensure
      drop_temp_tables
    end
  end

  private

  attr_reader :visits, :managing_campus_id, :date_begin, :date_end

  def source_sql(date_begin:, date_end:)
    <<~end_sql.strip
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
        AND user_visits.departs_at  >= #{date_begin}
        AND user_visits.arrives_at  <= #{date_end}
        AND visits.id IN (#{visits.select(:id).to_sql})
    end_sql
  end

  def drop_temp_tables
    AR_PART_1_TEMP_TABLES.each do |table|
      ActiveRecord::Base.connection.exec_query("DROP TEMPORARY TABLE IF EXISTS #{table};")
    end
  end
end
# rubocop:enable Metrics/ClassLength
