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

# Diagnostic
gem 'pry'

# Security
gem 'rbnacl-libsodium'

# Database
gem 'hirb'
gem 'sequel'

group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3'
end

group :production do
  gem 'pg'
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
  gem 'sendgrid-ruby'
end

group :development, :test do
  gem 'rerun'
end
