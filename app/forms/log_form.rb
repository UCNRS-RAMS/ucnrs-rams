# frozen_string_literal: true

class LogForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Log)
  end

  def self.create(params:, record:, record_about: nil)
    new(params: params, record: record, record_about: record_about).save
  end

  def initialize(params: {}, record: , record_about:)
    @log = Log.find_by(id: params[:id]) || Log.new(record: record, record_about: record_about)
    @params = params
    @record = record
    @action = Log::ACTIONS[params.delete(:action)]
    assign(params)
    @log.action = @action
    @log.metadata = metadata.to_json
    @log.log = log_details
  end
  
  attr_reader :log, :record, :params, :action

  def save
    return false if action == "updated" && record.previous_changes.reject! {|k, v| %w"updated_at sign_token".include? k }.blank?
    log.save
  end

  private

  delegate_missing_to :log

  def metadata
    {
      about: record_type,
      action: action,
      details: log_details,
      comment: "",
      about_type: record_about_type,
      about_id: record_about_id,
      changes: changes
    }
  end

  def changes
    if action != "created"
      record.previous_changes.reject { |key| key == "updated_at" || key == "sign_token" || key == "submitted_at" }
    else
      {}
    end
  end

  def user
    User.find(params[:user_id])
  end

  def log_time
    if action == "updated"
      record.updated_at
    elsif action == "created"
      record.created_at
    else
      Time.current
    end
  end

  def assign(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def log_details
    if action == "added"
      "#{user.full_name} #{action} #{about_type} to #{record_type} on #{log_time}"
    else
      "#{user.full_name} #{action} #{record_type} on #{log_time}"
    end
  end

  def about_type
    if record_about_type == "UserVisit"
      "visitor"
    elsif record_about_type == "ProjectTeamMembership"
      "team member"
    else
      record_about_type
    end
  end
end
