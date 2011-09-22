Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV["TWITTER_KEY"], ENV["TWITTER_SECRET"]
  provider :facebook, ENV["FACEBOOK_KEY"], ENV["FACEBOOK_SECRET"], {:scope => 'offline_access, publish_stream', :client_options => {:ssl => {:ca_path => "/etc/ssl/certs"}}}
end