# Be sure to restart your server when you modify this file.

# Set default URL options for Rails routes
# This ensures that URL helpers like url_for generate complete URLs with the host

Rails.application.routes.default_url_options = {
  # In production, use the actual host
  # AgentRH : à défaut de DEFAULT_HOST, on prend le nom d'hôte fourni par Render
  host: Rails.env.local? ? 'localhost' : (ENV['DEFAULT_HOST'].presence || ENV['RENDER_EXTERNAL_HOSTNAME']),
  # Use the correct port in development
  port: Rails.env.local? ? 3000 : nil,
  # Use HTTPS in production
  protocol: Rails.application.config.force_ssl ? 'https' : 'http'
}
