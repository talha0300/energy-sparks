source 'https://rubygems.org'

ruby '~> 2.7.6'

# Rails/Core
gem 'rails', '~> 6.0.4' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'jbuilder', '~> 2.5' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'bootsnap'
gem 'rack-canonical-host' # Redirect www to root
gem 'webpacker'
gem "image_processing", "~> 1.12"

gem 'puma', '6.4.0' # Use Puma as the app server
gem 'rack'
gem 'rack-attack'

# Database/Data
gem 'pg'
gem 'after_party' # load data after deploy
gem 'auto_strip_attributes', '~> 2.5'
gem 'closed_struct'
gem 'pg_search'

# Dashboard analytics
gem 'energy-sparks_analytics', git: 'https://github.com/Energy-Sparks/energy-sparks_analytics.git', tag: '4.0.3'
#gem 'energy-sparks_analytics', git: 'https://github.com/Energy-Sparks/energy-sparks_analytics.git', branch: 'optimise-usage-breakdown'
#gem 'energy-sparks_analytics', path: '../energy-sparks_analytics'

# Using master due to it having a patch which doesn't override Enumerable#sum if it's already defined
# Last proper release does that, causing all kinds of weird behaviour (+ not defined etc)
gem 'statsample', git: 'https://github.com/Energy-Sparks/statsample', tag: '2.1.1-energy-sparks', branch: 'update-gems-and-awesome-print'

# Assets
gem 'jquery-rails' # Use jquery as the JavaScript library
#gem 'sass-rails'# Use SCSS for stylesheets
gem 'uglifier' # Use Uglifier as compressor for JavaScript assets
gem 'bootstrap4-datetime-picker-rails' # For tempus dominus date picker
gem 'momentjs-rails'

# Pagination
gem 'pagy'

# Geocoding
gem 'geocoder'
gem 'rgeo-geojson'

# AWS S3 api
gem 'aws-sdk-s3'

# Assets for Emails
gem 'bootstrap-email'

# Frontend
gem 'bootstrap', '~> 4.3.0' # Use bootstrap for responsive layout
gem 'simple_form'
gem 'view_component'

# JS Templating
gem 'handlebars_assets'
# Template variables
gem "mustache", "~> 1.0"

# User input
gem 'trix-rails', require: 'trix'

# Auth & Users
gem 'devise' # Use devise for authentication
gem 'cancancan', '~> 3.0.1' # Use cancancan for authorization

# Utils
gem 'groupdate', '6.2.1' # Use groupdate to group usage stats
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem

# Bundle update installs 0.7.0 for some weird reason!
gem 'dotenv-rails', '~> 2.7.4' # Shim to load environment variables from .env into ENV in development.
gem 'friendly_id'

# Sitemap
gem 'sitemap_generator'

# For SMS notifications
gem 'twilio-ruby'

# Reduce log noise in dev and test
gem 'lograge'

# Exception handling
gem 'rollbar'
gem 'oj'

# Email service
gem 'mailgun_rails'
gem 'MailchimpMarketing'

# Eventbrite for training page
gem 'eventbrite_sdk'

gem 'wisper', '2.0.0'
gem 'stateful_enum', '0.6.0'
gem 'cocoon'

# Internationalisation
gem 'i18n-tasks', '~> 1.0.10'
gem 'mobility', '~> 1.2.9'
gem 'mobility-actiontext', '~> 1.1.1'

# Background jobs
gem "good_job", "~> 3.4.6"

# Rails 6.1 functionality. Can be removed when we upgrade.
gem 'delegated_type'

# Spreadsheet parsing
gem 'roo'
gem 'roo-xls'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem "bullet", require: false # use bullet to optimise queries
  gem 'rspec-rails', '~> 5.1.2'
  gem 'rspec-json_expectations'
  gem 'rails-controller-testing'
  gem "fakefs", require: "fakefs/safe"
  gem 'factory_bot_rails'
  gem 'climate_control'
  gem 'webmock'
  gem 'foreman'
  gem 'guard-rspec', require: false
  gem 'terminal-notifier', require: false
  gem 'terminal-notifier-guard', require: false
  gem 'rb-readline', require: false
  gem 'rubocop', '0.93.1'
  gem 'rubocop-rails', '2.9.1'
  gem 'rubocop-performance', '1.8.0'
  gem 'rubocop-rspec'
  gem 'wisper-rspec', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'annotate'
  gem 'pry'
  gem 'pry-byebug', '~>3.10.1'
  gem 'overcommit'
  gem 'fasterer'
  gem 'bundler-audit'
  gem 'brakeman'
  gem 'scout_apm'
#  gem 'rack-mini-profiler'
#  gem 'memory_profiler'
#  gem 'i18n-debug'
end

group :test do
  gem 'test-prof'
  gem 'capybara'
  gem 'capybara-email'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
  gem "webdrivers", '>= 5.3.0'
  gem 'simplecov', :require => false, :group => :test
  gem 'shoulda-matchers'
  gem 'timecop'
  gem "show_me_the_cookies"
end

gem 'sprockets', '3.7.2'
gem 'sass-rails', '5.1.0'
