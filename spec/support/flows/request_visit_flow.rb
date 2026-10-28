class RequestVisitFlow
  def initialize(page)
    @capybara_page = page
    @page_scope = nil
  end

  def visit_new_visit_page
    page.visit("/visits/new")
  end

  def page
    if @page_scope
      capybara_page.find(@page_scope)
    else
      capybara_page
    end
  end

  def within(selector, &block)
    begin
      @page_scope = selector
      block.call
    ensure
      @page_scope = nil
    end
  end

  def inside_amenity(amenity, &block)
    within(".amenity label[for='amenity-#{amenity.id}']", &block)
  end

  def select_reserve(name)
    page.select name, from: "visit_reserve_id"
  end

  def select_project(name)
    page.select name, from: "Project"
  end

  def select_amenity(title)
    page.find("div.amenity h3", text: title).click
  end

  def increment_count
    page.find(".more").click
  end

  def decrement_count
    page.find(".less").click
  end

  def has_subtotal?(text)
    page.has_css?(".subtotal", text: text)
  end

  private

  attr_reader :capybara_page
end
