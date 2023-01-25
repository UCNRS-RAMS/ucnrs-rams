class ReserveShowPresenter
  include ActionView::Helpers::TextHelper
  include Rails.application.routes.url_helpers

  def initialize(reserve:, selected_tab: nil)
    @reserve = reserve
    @selected_tab = selected_tab
  end

  delegate :id,
    :name,
    :address_line_1,
    :address_line_2,
    :address_line_3,
    :address_city,
    :address_postal_code,
    :state,
    :country,
    :logo_url,
    :logo_placeholder,
    :listing_photo_placeholder,
    :managing_campus,
    :description,
    :large_hero_photo_url,
    :large_hero_photo_placeholder,
    to: :reserve, prefix: true

  attr_accessor :selected_tab

  def reserve_personnel
    @reserve.personnel.map do |personnel|
      ReservePersonnelPresenter.new(personnel)
    end
  end

  def tab_content_path
    case selected_tab
    when "more_information"
      reserve_more_information_index_path(reserve_id)
    when "calendar"
      reserve_calendar_path(reserve_id, partial_name: "calendar", start_date: Date.today)
    when "waivers"
      reserve_waivers_path(reserve_id)
    when "rules_and_regulations"
      reserve_rules_and_regulations_path(reserve_id)
    else
      reserve_amenities_path(reserve_id)
    end
  end

  def tab_class(tab = nil)
    selected_tab == tab ? "active" : ""
  end

  def reserve_alert_message
    simple_format reserve.reserve_alert_message if reserve.reserve_alert_message.present?
  end

  def reserve_description
    simple_format reserve.description if reserve.description.present?
  end

  def large_hero_photo_src
    reserve_large_hero_photo_url || ActionController::Base.helpers.image_path(reserve_large_hero_photo_placeholder)
  end

  def logo_src
    reserve_logo_url(:medium) || reserve_logo_placeholder
  end

  private

  def reserve
    ReservePresenter.new(@reserve)
  end
end
