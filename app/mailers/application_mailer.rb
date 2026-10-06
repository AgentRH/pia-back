class ApplicationMailer < ActionMailer::Base
  # AgentRH : expéditeur lu dans EMAIL_FROM, à défaut dans les credentials Rails
  default from: ENV['EMAIL_FROM'].presence || Rails.application.credentials.email_from
  layout 'mailer'
end
