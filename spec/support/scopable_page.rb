class ScopablePage
  def initialize(page)
    @page = page
  end

  delegate_missing_to :page

  def page
    if @page_scope
      @page.find(@page_scope)
    else
      @page
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
end
