OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '323632880151-6djugqrruttm789vb0ljs6n8eq1g3a6j.apps.googleusercontent.com', 'PxGybt8ilewniHlF87DBEkgu', {client_options: {ssl: {ca_file: Rails.root.join("cacert.pem").to_s}}}
end