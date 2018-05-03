ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:problems].delete
  app.DB[:groups].delete
end

DATA = {}
DATA[:problems] = YAML.safe_load File.read('db/seeds/problem_seeds.yml')
DATA[:groups] = YAML.safe_load File.read('db/seeds/group_seeds.yml')
