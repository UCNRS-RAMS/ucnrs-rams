RSpec::Matchers.define :display_error do |error|
  match do |page|
    selector = if @field_text
      "label:contains('#{@field_text}')"
    elsif @field_id
      "label##{@field_id}"
    end
    page.find("#{selector} .error_messages", text: error)
  end

  chain :for_field do |field_text|
    @field_text = field_text
  end

  chain :for_field_with_id do |field_id|
    @field_id = field_id
  end
end
