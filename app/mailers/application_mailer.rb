class ApplicationMailer < ActionMailer::Base
  # AgentRH : expéditeur lu dans EMAIL_FROM, à défaut dans les credentials Rails
  default from: ENV['EMAIL_FROM'].presence || Rails.application.credentials.email_from
  layout 'mailer'

  private

  # AgentRH : contexte commun à tous les emails.
  #   FRONT_URL    adresse du site vue par les utilisateurs (ex. https://pia-argos.agentrh.ai)
  #   CLIENT_NAME  nom du client de l'instance (ex. Argos Vétérinaire)
  # Les deux sont facultatives : sans elles, les emails restent corrects mais
  # sans bouton ni nom de client.
  def prepare_context
    @front_url = ENV['FRONT_URL'].to_s.strip.chomp('/')
    @client_name = ENV['CLIENT_NAME'].to_s.strip
    @workspace = if @client_name.empty?
                   "l'espace conformité AgentRH"
                 else
                   "l'espace conformité AgentRH ouvert pour #{@client_name}"
                 end
  end

  def subject_suffix
    @client_name.to_s.empty? ? '' : " · #{@client_name}"
  end

  # Lien vers le site, avec un paramètre lu par la page d'accueil
  # (activation=CODE ou reset=CODE). Renvoie nil si FRONT_URL n'est pas défini.
  def front_link(query = nil)
    return nil if @front_url.to_s.empty?

    query ? "#{@front_url}/#/?#{query}" : @front_url
  end
end
