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

  attr_accessor :about
  attr_reader :log

  def save
    if action == "updated" &&
       record_about.previous_changes
         .reject! { |k, _| %w[updated_at sign_token].include? k }
         .blank?
      return false
    end

    log.save
  end

  private

  delegate_missing_to :log

  def metadata(params)
    {
      about: about,
      action: action,
      details: log_details,
      comment: comment,
      about_type: record_about_type,
      about_id: record_about_id,
      changes: changes,
    }
  end

  def changes
    if action == "updated"
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

  def user=(value)
    if value == :system
      log.user_id = 0
    elsif value.is_a?(ActiveRecord::Base)
      log.user = value
    end
  end

  def log_details
    [].tap do |details|
      details << "* #{Time.now.utc}"
      details << "| #{log_action}"

      if log.user.present?
        details << "::by:: ##{log.user_id} #{log.user.full_name}"
      else
        details << "::by:: system"
      end

      if log.record_about.present?
        details << "| #{log.record_about.class} ##{log.record_about.id}"
      end
    end.join(" ").squish
  end

  def log_action
    "#{log.record_about.present? ? log.record_about.class : about} #{action}"
  end

  def changes_except_list
    %w[updated_at sign_token submitted_at]
  end
end
