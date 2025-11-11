class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@#{smtp_settings[:domain]}"
  layout "mailer"
  prepend_view_path "app/views/mails"
end
