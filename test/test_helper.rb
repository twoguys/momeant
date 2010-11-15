ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

require 'rails/test_help'
require 'shoulda'
require 'coulda'
require 'factory_girl'

class ActiveSupport::TestCase
  include Coulda
  
  Factory.find_definitions

  # Add more helper methods to be used by all tests here...
end