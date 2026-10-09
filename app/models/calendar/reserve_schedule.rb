module Calendar
  class ReserveSchedule
    TITLE_LIMIT = 80

    def initialize(reserve:, date_range:, statuses: Entry::STATUSES, kinds: Entry::KINDS, groups: nil)
      @reserve    = reserve
      @date_range = date_range
      @statuses   = statuses
      @kinds      = kinds
      @groups     = groups
    end

    def entries
      return [] if reserve.nil? || statuses.empty?

      rows = []
      rows.concat(visit_entries)   if kinds.include?(:visit)
      rows.concat(user_entries)    if kinds.include?(:user)
      rows.concat(amenity_entries) if kinds.include?(:amenity)

      rows.select { |e| e.starts_on && e.ends_on && statuses.include?(e.status) }
    end

    def visitor_counts
      return Hash.new(0) if reserve.nil?

      counts = Hash.new(0)
      user_visits.each do |uv|
        next unless statuses.include?(user_visit_calendar_status(uv))
        next if uv.arrives_at.nil? || uv.departs_at.nil?

        head_count = uv.count.to_i
        next if head_count.zero?

        first_day = [ uv.arrival_date, date_range.first ].max
        last_day  = [ uv.departure_date, date_range.last ].min
        next if first_day > last_day

        (first_day..last_day).each { |date| counts[date] += head_count }
      end
      counts
    end

    private

    attr_reader :reserve, :date_range, :statuses, :kinds, :groups

    def span_start
      @span_start ||= date_range.first.beginning_of_day
    end

    def span_end
      @span_end ||= date_range.last.end_of_day
    end

    def user_entries
      user_visits.map do |uv|
        Entry.new(
          id: uv.id,
          kind: :user,
          status: user_visit_calendar_status(uv),
          title: user_visit_title(uv),
          visit_id: uv.visit_id,
          starts_on: uv.arrives_at&.to_date,
          ends_on: uv.departs_at&.to_date,
        )
      end
    end

    def amenity_entries
      amenity_visits.map do |av|
        Entry.new(
          id: av.id,
          kind: :amenity,
          status: amenity_visit_calendar_status(av),
          title: amenity_visit_title(av),
          visit_id: av.visit_id,
          starts_on: av.arrives&.to_date,
          ends_on: av.departs&.to_date,
        )
      end
    end

    def visit_entries
      visits.flat_map do |visit|
        status = visit_calendar_status(visit)
        title = visit_title(visit)
        visit_segments(visit).each_with_index.map do |(starts, ends), i|
          Entry.new(
            id: "visit-#{visit.id}-seg-#{i}",
            kind: :visit,
            status: status,
            title: title,
            visit_id: visit.id,
            starts_on: starts,
            ends_on: ends,
          )
        end
      end
    end

    def visit_segments(visit)
      ranges = []
      visit.user_visits.each do |uv|
        next if uv.arrives_at.nil? || uv.departs_at.nil?
        ranges << [ uv.arrival_date, uv.departure_date ]
      end
      visit.amenity_visits.each do |av|
        next if av.arrives.nil? || av.departs.nil?
        ranges << [ av.arrives.to_date, av.departs.to_date ]
      end
      return [] if ranges.empty?

      ranges.sort_by!(&:first)

      merged = [ ranges.first.dup ]
      ranges.drop(1).each do |start_d, end_d|
        last_end = merged.last[1]
        if start_d <= last_end + 1
          merged.last[1] = [ last_end, end_d ].max
        else
          merged << [ start_d, end_d ]
        end
      end
      merged
    end

    def user_visits
      @user_visits ||= UserVisit
        .at_reserve(reserve)
        .having_between_time(date_start: span_start, date_end: span_end)
        .preload(:user, :visit)
        .order(:visit_id)
    end

    def amenity_visits
      @amenity_visits ||= AmenityVisit
        .at_reserve(reserve)
        .having_between_time(date_start: span_start, date_end: span_end)
        .with_amenity_group(groups)
        .preload(:amenity, :visit)
        .order(:visit_id)
    end

    def visits
      @visits ||= Visit
        .by_reserve(reserve)
        .having_between_time_for(
          date_range_option: :visit_date_range,
          date_start: span_start,
          date_end: span_end,
        )
        .preload(:user_visits, :amenity_visits)
        .order(:id)
    end

    def visit_calendar_status(visit)
      case visit.status
      when "approved"   then :approved
      when "in_review"  then :in_review
      when "incomplete" then :incomplete
      when "cancelled"  then :cancelled
      when "denied"     then :denied
      end
    end

    def visit_title(visit)
      purpose = visit.purpose_of_visit.to_s.squish
      return "Visit ##{visit.id}" if purpose.blank?

      "#{purpose.truncate(TITLE_LIMIT, omission: "…")} [Visit ##{visit.id}]"
    end

    def user_visit_title(user_visit)
      role_label = user_visit.role&.humanize
      user_name = user_visit.user&.full_name || "(no user)"
      count = user_visit.count.to_i
      count > 1 ? "#{role_label} (#{count})" : user_name
    end

    def amenity_visit_title(amenity_visit)
      title = amenity_visit.amenity&.title
      count = amenity_visit.number_of_people.to_i
      prefix = amenity_visit.invoiced? ? "$-" : ""
      "#{prefix}#{title} (#{count})"
    end

    def user_visit_calendar_status(user_visit)
      return :incomplete if user_visit.visit&.incomplete?

      enum_to_status_sym(user_visit.status)
    end

    def amenity_visit_calendar_status(amenity_visit)
      return :incomplete if amenity_visit.visit&.incomplete?

      enum_to_status_sym(amenity_visit.status)
    end

    def enum_to_status_sym(status)
      case status
      when "approved"  then :approved
      when "in_review" then :in_review
      when "cancelled" then :cancelled
      when "denied"    then :denied
      end
    end
  end
end
