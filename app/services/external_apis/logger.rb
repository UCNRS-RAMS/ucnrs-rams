# frozen_string_literal: true

module ExternalApis
  class Logger
    def info(message)
      write(:info, message)
    end

    def warn(message)
      write(:warn, message)
    end

    def error(context:, error:)
      message = "#{context}: #{error.message}"
      Rails.logger.error(message)
      Rails.logger.error(error.backtrace) if error.backtrace.present?
      print_to_console(:error, message)
    end

    private

    def write(level, message)
      Rails.logger.public_send(level, message)
      print_to_console(level, message)
    end

    def print_to_console(level, message)
      return unless Rails.env.development? || Rails.env.dev_server? || ENV['RAILS_LOG_TO_STDOUT'].present?

      $stdout.puts("[#{level.to_s.upcase}] #{message}")
    end
  end
end
