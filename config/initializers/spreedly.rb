if Rails.env.test?
  require 'spreedly/mock'
else
  require 'spreedly'
end

Spreedly.configure(ENV["SPREEDLY_SITE_NAME"],ENV["SPREEDLY_SITE_TOKEN"])