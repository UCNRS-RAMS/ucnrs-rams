class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@#{ENV.fetch("SMTP_DOMAIN", "example.com")}"
  layout "mailer"
  prepend_view_path "app/views/mails"
end
