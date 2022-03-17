module ApplicationHelper
  def body_class
    controller_name = controller.controller_name
    action_name = controller.action_name
    "#{controller_name} #{controller_name}-#{action_name}"
  end

  def active_class_for(resource)
    "active" if controller.controller_name == resource
  end

  def num_of_units(arr_time, dep_time, units_type)
    case units_type.downcase
    when "each", "use", "session", "person", "facility", "unit", "mile"
      num_units               = 1

    when "hour"
      num_units               = (arr_time - arr_time) / 1.hour

    when "day"
      num_units               = (dep_time.to_date - arr_time.to_date).to_i + 1

    when "night"
      num_units               = (dep_time.to_date - arr_time.to_date).to_i

    when "4 hours"
      num_units               = (dep_time - arr_time) / 4.hours

    when "8 hours"
      num_units               = (dep_time - arr_time) / 8.hours

    when "week"
      num_units               = (dep_time.to_date - arr_time.to_date).to_i + 1
      num_units               /= 7.0
      num_units               = num_units.ceil

    when "quarter"
      num_units               = (dep_time.to_date - arr_time.to_date).to_i + 1
      num_units               /= 92.0
      num_units               = num_units.ceil

    when "semi-annual"
      num_units               = (dep_time.to_date - arr_time.to_date).to_i + 1
      num_units               /= 183.0
      num_units               = num_units.ceil

    when "year"
      num_units               = (dep_time.to_date - arr_time.to_date).to_i + 1
      num_units               /= 365.0
      num_units	              = num_units.ceil

    when "month"
      arrival_date            = arr_time.to_date
      departure_date          = dep_time.to_date

      if arrival_date == arrival_date.beginning_of_month
          arrival_full_month  = 1
          arrival_partial     = 0

      else
          arrival_full_month  = 0
          arrival_partial     = (arrival_date.end_of_month - arrival_date).to_i

      end

      if departure_date == departure_date.end_of_month
          departure_full_month  = 1
          departure_partial     = 0

      else
          departure_full_month  = 0
          departure_partial     = (departure_date - departure_date.beginning_of_month).to_i

      end

      # num_units 		= Math_Ceil:(#moFullMonths + (#moDaysFirstMonth + #moDaysLastMonth) * 12.0 / 365.0)]
      full_months     = ((departure_date.year * 12 + departure_date.month) -
                          (arrival_date.year * 12 + arrival_date.month)).abs - 1
      num_units       = (full_months + arrival_full_month + departure_full_month +
                          ((arrival_partial + departure_partial) * 12.0 / 365.0)).ceil
    end

    num_units
  end
end
