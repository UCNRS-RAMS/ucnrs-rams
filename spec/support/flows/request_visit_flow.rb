class RequestVisitFlow
  def initialize(page)
    @page = page
  end

  attr_reader :page

  def visit_new_visit_page
    page.visit("/visits/new")
  end

  def on_new_visit_page?
    page.has_css?("body.visits-new") || page.has_css?("body.visits-create")
  end

  def has_special_needs_section?(content = nil)
    if content
      page.has_css?("p.special-needs-statement", text: content)
    else
      page.has_css?("p.special-needs-statement")
    end
  end

  def has_alert_section?(content = nil)
    if content
      page.has_css?("div.alert_message", text: content)
    else
      page.has_css?("div.alert_message")
    end
  end

  def has_amenities?(*names)
    if names.empty?
      page.has_css?("div.amenity")
    else
      names.all? do |name|
        byebug
        page.has_css?("div.amenity h3", text: name)
      end
    end
  end

  def select_reserve(name)
    page.select name, from: "Reserve"
  end
end
