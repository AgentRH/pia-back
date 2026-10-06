# AgentRH : prépare une instance sans passer par la console Rails.
# La tâche est lancée à chaque démarrage et ne fait rien si tout est déjà en place.
#
#   OAUTH_CLIENT_ID / OAUTH_CLIENT_SECRET : identifiants de l'application OAuth,
#     à recopier dans le front (PIA_CLIENT_ID / PIA_CLIENT_SECRET).
#   ADMIN_EMAIL / ADMIN_PASSWORD : premier compte administrateur, créé seulement
#     si la base ne contient encore aucun utilisateur.
namespace :agentrh do
  desc 'Crée l\'application OAuth et le premier administrateur si nécessaire'
  task bootstrap: :environment do
    client_id = ENV['OAUTH_CLIENT_ID'].to_s.strip
    client_secret = ENV['OAUTH_CLIENT_SECRET'].to_s.strip

    if client_id.empty? || client_secret.empty?
      puts '[agentrh] OAUTH_CLIENT_ID ou OAUTH_CLIENT_SECRET absent : application OAuth non créée.'
    else
      oauth_app = Doorkeeper::Application.find_by(uid: client_id)
      if oauth_app.nil?
        Doorkeeper::Application.create!(
          name: 'PIA',
          redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
          scopes: %w[read write],
          uid: client_id,
          secret: client_secret
        )
        puts '[agentrh] Application OAuth créée.'
      elsif oauth_app.secret != client_secret
        oauth_app.update!(secret: client_secret)
        puts '[agentrh] Secret de l\'application OAuth mis à jour.'
      else
        puts '[agentrh] Application OAuth déjà en place.'
      end
    end

    admin_email = ENV['ADMIN_EMAIL'].to_s.strip.downcase
    admin_password = ENV['ADMIN_PASSWORD'].to_s

    if User.exists?
      puts '[agentrh] Des utilisateurs existent déjà : aucun compte créé.'
    elsif admin_email.empty? || admin_password.empty?
      puts '[agentrh] ADMIN_EMAIL ou ADMIN_PASSWORD absent : aucun compte administrateur créé.'
    else
      admin = User.new(
        email: admin_email,
        password: admin_password,
        password_confirmation: admin_password,
        firstname: ENV['ADMIN_FIRSTNAME'].to_s.strip,
        lastname: ENV['ADMIN_LASTNAME'].to_s.strip
      )
      admin.is_technical_admin = true
      admin.is_functional_admin = true
      admin.is_user = true

      if admin.save
        admin.unlock_access!
        puts "[agentrh] Compte administrateur créé pour #{admin_email}."
      else
        # On n'interrompt pas le démarrage : le motif est dans les journaux.
        puts "[agentrh] Compte administrateur NON créé : #{admin.errors.full_messages.join(' ; ')}"
        puts '[agentrh] Rappel : 12 caractères minimum, avec majuscule, minuscule, chiffre et caractère spécial.'
      end
    end
  end
end
