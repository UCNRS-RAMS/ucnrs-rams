class ApplicationMailer < ActionMailer::Base
  default from: "donotreply@ucnrs.com"
  layout "mailer"
  prepend_view_path "app/views/mails"
end
