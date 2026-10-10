# frozen_string_literal: true

module CalendarGridHelper
  CALENDAR_ENTRY_DATA = {
    calendar_highlight_target: "entry",
    action: "mouseover->calendar-highlight#highlight " \
            "mouseout->calendar-highlight#unhighlight",
    turbo_frame: "modal-content"
  }.freeze

  def calendar_entry_link(entry, *extra_classes)
    link_to entry.href,
            class: [ "cal-entry", entry.css_class, *extra_classes ],
            title: entry.title,
            data: CALENDAR_ENTRY_DATA.merge(entry.wrap_attributes) do
      tag.div entry.title, class: "cal-entry-label"
    end
  end
end
