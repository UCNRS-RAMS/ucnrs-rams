# frozen_string_literal: true

class LogForm2
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Log)
  end

  def self.create(params:)
    new(
      params: params,
    ).save
  end

  def initialize(params: {})
    @log = Log.find_by(id: params[:id]) || Log.new
    assign(params)
    @log.metadata = metadata(params).to_json
    @log.log = log_details.squish
  end

  attr_reader :log

  def save
    if action == "updated" && record_about.previous_changes.reject! {|k, v| %w[updated_at sign_token].include? k }.blank?
      return false
    end

    log.save
  end

  private

  delegate_missing_to :log

  def metadata(params)
    {
      about: record_type,
      action: action,
      details: log_details,
      comment: "",
      about_type: record_about_type,
      about_id: record_about_id,
      changes: record.changes
    }
  end

  def changes
    if action != "created"
      record_about.previous_changes.except(*changes_except_list)
    else
      {}
    end
  end

  def assign(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def log_details
    "* #{Time.now.utc}
    | #{log.record_about.class} #{action} ::by:: ##{log.user_id} #{log.user.full_name}
    | #{log.record_about.class} ##{log.record_about.id}"
      .squish
  end

  def changes_except_list
    %w[updated_at sign_token submitted_at]
  end
end
