# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 8.1.3'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.24', require: false

# Use jwt to validate Google authentication tokens prior to calling
# the Google auth API
gem 'jwt', '~> 3.2.0'

# Use Faraday to make third-party API calls
gem 'faraday', '~> 2.14.3'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem 'rack-cors', '~> 3.0.0'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', '~> 1.11.1', platforms: %i[mri windows], require: 'debug/prelude'

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem 'rubocop-rails-omakase', '~> 1.1.0', require: false

  # Use rubocop-performance to enforce performance styles
  gem 'rubocop-performance', '~> 1.26.1'

  # Use rubocop-rspec for linting tests
  gem 'rubocop-rspec', '~> 3.10.2'

  # Use rubocop-rspec_rails for more specific linting rules
  gem 'rubocop-rspec_rails', '2.32.0'

  # Use rubocop-factory_bot for linting factories
  gem 'rubocop-factory_bot', '~> 2.28.0'

  # Test with RSpec
  gem 'rspec-rails', '~> 8.0.4'

  # User factory_bot factories for test data
  gem 'factory_bot_rails', '~> 6.5.1'

  # Use Database Cleaner to truncate the database between test runs
  gem 'database_cleaner-active_record', '~> 2.2.2'
end
