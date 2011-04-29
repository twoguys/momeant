ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

require 'rake'
require 'rails/test_help'
require 'shoulda'
require 'coulda'
require 'factory_girl'
require 'capybara/rails'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end

Coulda.default_testcase_class = ActionController::IntegrationTest

# Load shared test steps for Coulda
FileList[File.expand_path('integration/steps/**/*_steps.rb', File.dirname(__FILE__))].each do |f|
  require f
end

DatabaseCleaner.strategy = :truncation
#Capybara.default_wait_time = 5

class ActionController::IntegrationTest
  include Capybara
  extend WebSteps
end

class FullStackTest < ActionController::IntegrationTest
  self.use_transactional_fixtures = false
  
  def setup
    Capybara.current_driver = :selenium
  end
  
  def teardown
    Capybara.use_default_driver
    DatabaseCleaner.clean
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end

class ActiveSupport::TestCase
  
  Factory.find_definitions

  # Add more helper methods to be used by all tests here...
end

Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session) 