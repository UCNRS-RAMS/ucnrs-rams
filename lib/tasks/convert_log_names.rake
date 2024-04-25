namespace :db do
  desc "Convert logs to rams3 naming convention."
  task convert_log_names: :environment do
    CONVERT_MAP = {
      "application submitted" => "submitted",
      "application updated" => "updated",
      "application deleted" => "deleted",
      "reservation submitted" => "submitted",
      "reservation updated" => "updated",
      "reservation deleted" => "deleted",
      "visit updated" => "updated",
      "visit cancelled" => "cancelled",
      "visit deleted" => "deleted",
      "asset updated" => "updated",
      "asset cancelled" => "cancelled",
      "asset deleted" => "deleted",
      "invoice created" => "created",
      "invoice updated" => "updated",
      "invoice deleted" => "deleted",
      "invoice sent" => "sent",
      "requested" => "cancelation requested",

      "Application" => "Project",
      "Activity" => "Visit",
      "ActPerson" => "UserVisit",
      "ActAsset" => "AmenityVisit",
      "Invoice" => "Invoice",

      "reservation" => "Visit",
      "reservation cancellation" => "Visit",
      "application" => "Project",
      "activity" => "Visit",
      "visit" => "UserVisit",
      "asset" => "AmenityVisit",
      "resource request" => "AmenityVisit",
      "invoice" => "Invoice",
    }

    ActiveRecord::Base.connection.exec_query("SET FOREIGN_KEY_CHECKS=0;")
    ActiveRecord::Base.connection.exec_query("DROP TABLE IF EXISTS `logs_backup`;")
    ActiveRecord::Base.connection.exec_query("SET FOREIGN_KEY_CHECKS=1;")

    ActiveRecord::Base.connection.exec_query("CREATE TABLE logs_backup LIKE logs;")
    ActiveRecord::Base.connection.exec_query("INSERT INTO logs_backup SELECT * FROM logs;")

    Log.find_each do |log|
      metadata = log.metadata
      metadata = metadata.to_json if metadata.is_a?(Hash)
      metadata = JSON.parse(metadata, object_class: OpenStruct)

      log.action = CONVERT_MAP[log.action] if CONVERT_MAP[log.action].present?
      log.record_type = CONVERT_MAP[log.record_type] if CONVERT_MAP[log.record_type].present?
      log.record_about_type = CONVERT_MAP[log.record_about_type] if CONVERT_MAP[log.record_about_type].present?

      metadata.action = CONVERT_MAP[metadata.action] if CONVERT_MAP[metadata.action].present?
      metadata.about = CONVERT_MAP[metadata.about] if CONVERT_MAP[metadata.about].present?
      metadata.about_type = CONVERT_MAP[metadata.about_type] if CONVERT_MAP[metadata.about_type].present?

      metadata = metadata.deep_to_h

      metadata = metadata.to_json unless log.metadata.is_a?(Hash)

      log.metadata = metadata

      log.save(validate: false)
    end
  end
end
