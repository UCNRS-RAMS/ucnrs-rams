ActionView::Base.field_error_proc = proc do |html_tag, instance, *args|
  fragment = Nokogiri::HTML.fragment(html_tag)
  field = fragment.at("label,input,select,textarea")

  model = instance.object
  method_name = instance.instance_variable_get("@method_name")
  error_message = model.errors[method_name].reject(&:blank?).sort.uniq.join(", ")

  # rubocop:disable Rails/OutputSafety
  field.add_class("error")
  if field.name == "label"
    field << "<span class='error_messages'>#{error_message}</span>".html_safe
    field.to_s.html_safe
  elsif field.present?
    field.to_s.html_safe
  else
    html_tag
  end
  # rubocop:enable Rails/OutputSafety
end
