# frozen_string_literal: true

# run pry -r <path/to/this/file>
require 'rack/test'
include Rack::Test::Methods

require_relative '../app'
require_relative '../models/init'

def app
  Wefix::Api
end
