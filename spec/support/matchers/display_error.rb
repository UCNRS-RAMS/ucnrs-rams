RSpec::Matchers.define :display_error do |error|
  match do |page|
    label = if @field_text
              page.find("label", text: @field_text, exact_text: @boolean)
            elsif @field_id
              page.find("label", id: @field_id)
            end
    label
      .first(:xpath, "..")
      .find(".error_messages", text: error)
  end

  chain :for_field do |field_text|
    @field_text = field_text
  end

  chain :for_field_with_id do |field_id|
    @field_id = field_id
  end

  chain :exact_text do |boolean|
    @boolean = boolean == true
  end
end
