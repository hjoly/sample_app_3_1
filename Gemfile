# bundle install --without production

source 'http://rubygems.org'

gem 'rails', '3.1.0'

# gem 'arel', '2.2.1'

# # For enhancing ActiveRecord with support for DB constraints
# gem 'schema_plus', '~> 0.2.0'
# gem 'schema_validations', '~> 0.1.2'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'gravatar_image_tag', '1.0.0'
gem 'will_paginate', '3.0.1'
gem 'haml', '3.1.3'
gem 'builder', '3.0.0'
gem 'possessive', '~> 1.0.0'

# Used for modifying an email before it gets sent. (For testing purposes)
gem 'mail', '~> 2.3.0'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '  ~> 3.1.0'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier'
end

# Is replacing: gem 'prototype-rails'
gem 'jquery-rails'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development do
  gem 'sqlite3', '1.3.4'
  gem 'rspec-rails', '2.6.1'
  gem 'annotate', '~>2.4.1.beta'
  gem 'faker', '1.0.0'
end

group :test do
  gem 'sqlite3', '1.3.4'
  gem 'rspec-rails', '2.6.1'
  gem 'webrat', '0.7.3'
  gem 'spork', '0.9.0.rc8'
  gem 'factory_girl_rails', '1.2.0'
  gem 'ZenTest', '4.5.0'

  # Pretty printed test output
  gem 'turn', :require => false
end

group :production do
  gem 'pg'
  gem 'execjs', '1.2.9'
  gem 'rubytracer', '0.1.0'
end
