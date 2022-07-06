# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '=5.2.6'
# Use sqlite3 as the database for Active Record

gem 'pg', '=0.18.4'

# Use Puma as the app server
gem 'puma', '=3.12.6'
# Use SCSS for stylesheets
# gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '=4.2.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'execjs', '=2.8.1'
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '=4.2.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '=2.11.2'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'vault', '=0.16.0'

gem 'secure_headers', '=6.3.2'

gem 'rack-cors', '=1.1.1'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'omniauth', '~> 1.6', '>= 1.6.1'
gem 'omniauth-azure-activedirectory', '=1.0.0'

gem 'omniauth-azure-oauth2', '=0.0.10'

gem 'foreman', '=0.87.2'
gem 'webpacker', '=5.4.0'

gem 'pry'

gem 'i18n', '=1.7.0'

gem 'nokogiri', '=1.10.5'

gem 'globalid', '=0.4.2'

gem 'addressable', '=2.7.0'

gem 'msgpack', '=1.3.1'

gem 'ffi', '=1.11.2'

gem 'thor', '=0.20.3'

gem 'sprockets', '=4.0.2'

gem 'sprockets-rails', '=3.2.2'

gem 'rest-client', '=2.1.0'

gem 'public_activity', '=1.6.4'

gem 'font-awesome-rails', '=4.7.0.7'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails', '~> 5.0.0'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'

  gem 'simplecov'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
