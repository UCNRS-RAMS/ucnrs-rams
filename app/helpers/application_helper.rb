module ApplicationHelper
  def body_class
    controller_name = controller.controller_name
    action_name = controller.action_name
    "#{controller_name} #{controller_name}-#{action_name}"
  end
end
