# AgentRH : les réglages SMTP sont lus d'abord dans les variables
# d'environnement (SMTP_*), puis, à défaut, dans les credentials Rails comme
# dans le logiciel d'origine.
credentials = Rails.application.credentials

smtp_port = ENV['SMTP_PORT'].presence || credentials.smtp_port
smtp_authentication = ENV['SMTP_AUTHENTICATION'].presence || credentials.smtp_authentication
smtp_starttls = ENV['SMTP_ENABLE_STARTTLS_AUTO'].presence

ActionMailer::Base.smtp_settings = {
  address: ENV['SMTP_ADDRESS'].presence || credentials.smtp_address,
  port: smtp_port.nil? ? nil : smtp_port.to_i,
  domain: ENV['SMTP_DOMAIN'].presence || credentials.smtp_domain,
  user_name: ENV['SMTP_USERNAME'].presence || credentials.smtp_user_name,
  password: ENV['SMTP_PASSWORD'].presence || credentials.smtp_password,
  authentication: smtp_authentication.nil? ? nil : smtp_authentication.to_sym,
  enable_starttls_auto: smtp_starttls.nil? ? credentials.smtp_enable_starttls_auto : smtp_starttls != 'false'
}
