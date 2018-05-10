ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  Credence::Account.dataset.destroy
  Credence::Group.dataset.destroy
end

DATA = {}
DATA[:accounts] = YAML.load File.read('db/seeds/accounts_seed.yml')
DATA[:problems] = YAML.load File.read('db/seeds/problems_seed.yml')
DATA[:groups] = YAML.load File.read('db/seeds/groups_seed.yml')