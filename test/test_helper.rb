ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

require 'rake'
require 'rails/test_help'
require 'shoulda'
require 'coulda'
require 'factory_girl'
require 'webrat'

Coulda.default_testcase_class = ActionController::IntegrationTest

Webrat.configure do |config|
  config.mode = :rack
end

# Load shared test steps for Coulda
FileList[File.expand_path('integration/steps/**/*_steps.rb', File.dirname(__FILE__))].each do |f|
  require f
end

class ActiveSupport::TestCase
  
  Factory.find_definitions

  # Add more helper methods to be used by all tests here...
end