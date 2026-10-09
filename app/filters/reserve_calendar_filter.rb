# frozen_string_literal: true

class ReserveCalendarFilter
  GROUP_COUNT = 5

  STATUS_PARAMS = {
    show_approved: :approved,
    show_in_review: :in_review,
    show_incomplete: :incomplete,
    show_cancelled: :cancelled,
    show_denied: :denied
  }.freeze

  KIND_PARAMS = {
    show_visits: :visit,
    show_others: :user,
    show_amenity: :amenity
  }.freeze

  DEFAULTS = {
    show_approved: true, show_in_review: true, show_incomplete: true,
    show_cancelled: false, show_denied: false,
    show_visits: true, show_others: false, show_amenity: true,
    group1: true, group2: true, group3: true, group4: true, group5: true
  }.freeze

  def self.from_params(params)
    new(selections_from(params), **viewed_period_from(params))
  end


  def self.selections_from(params)
    return DEFAULTS if params[:show_approved].blank?

    DEFAULTS.keys.index_with { |key| params[key] == "true" }
  end

  def self.viewed_period_from(params)
    if params[:month].to_i.between?(1, 12) && params[:year].present?
      { month: params[:month].to_i, year: params[:year].to_i }
    else
      { month: Date.current.month, year: Date.current.year }
    end
  end
  private_class_method :selections_from, :viewed_period_from

  def initialize(selections, month:, year:)
    @selections = selections.freeze
    @month = month
    @year = year
  end

  attr_reader :month, :year

  DEFAULTS.each_key do |key|
    define_method("#{key}?") { @selections[key] }
  end

  def group?(number)
    @selections[:"group#{number}"]
  end

  def statuses
    STATUS_PARAMS.filter_map { |param, status| status if @selections[param] }
  end

  def kinds
    KIND_PARAMS.filter_map { |param, kind| kind if @selections[param] }
  end

  def group_filter
    active = (1..GROUP_COUNT).select { |n| group?(n) }
    return nil if active.empty? || active.size == GROUP_COUNT

    active.map(&:to_s)
  end
end
