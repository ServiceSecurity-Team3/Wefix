# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.5.1'

# Web API
gem 'json'
gem 'puma'
gem 'roda'

# Configuration
gem 'econfig'
gem 'rake'
gem 'pry'

# Security
gem 'rbnacl-libsodium'

# Database
gem 'sequel'
gem 'hirb'
group :development, :test do
  gem 'sqlite3'
end

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'rack-test'
end

# Development
group :development do
  gem 'rubocop'
end

group :development, :test do
  gem 'rerun'
end
