# frozen_string_literal: true
require_relative 'init'
require './app.rb'
run Wefix::Api.freeze.app
