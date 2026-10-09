module Calendar
  class Entry
    KINDS = %i[user amenity visit].freeze
    STATUSES = %i[approved in_review cancelled denied incomplete].freeze

    attr_reader :id, :kind, :status, :title, :visit_id, :starts_on, :ends_on, :href

    def initialize(id:, kind:, status:, title:, visit_id:, starts_on:, ends_on:, href: nil)
      @id = id
      @kind = kind
      @status = status
      @title = title
      @visit_id = visit_id
      @starts_on = starts_on
      @ends_on = ends_on
      @href = href
    end

    def with_href(href)
      self.class.new(
        id: id, kind: kind, status: status, title: title, visit_id: visit_id,
        starts_on: starts_on, ends_on: ends_on, href: href
      )
    end

    def user?
      kind == :user
    end

    def amenity?
      kind == :amenity
    end

    def visit?
      kind == :visit
    end

    def css_class
      "cal-#{kind}-#{status}".tr("_", "-")
    end

    def wrap_attributes
      case kind
      when :user    then { entry_id: id, visit_id: visit_id, user_visit_id: id }
      when :amenity then { entry_id: id, visit_id: visit_id, amenity_visit_id: id }
      when :visit   then { entry_id: id, visit_id: visit_id }
      end
    end
  end
end
