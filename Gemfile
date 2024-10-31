source "https://rubygems.org"

ruby '3.3.1'
gem "rails", "~> 7.2.2"
gem "propshaft"
gem "pg", ">= 1.5"
gem "puma", ">= 6.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"
gem "redis", ">= 4.0.1"
# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"
gem "bcrypt", "~> 3.1.7"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "image_processing", "~> 1.2"
gem 'prawn'
gem 'rqrcode'
gem 'chunky_png'
gem 'activerecord-import'
gem 'csv'
gem 'yaml_db'
gem 'mime-types'
gem 'good_job'
gem 'mini_magick'
gem 'addressable'
gem 'wicked_pdf'               # For PDF generation
gem 'wkhtmltopdf-binary'       # Dependency for Wicked PDF
gem 'dotenv-rails'

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

gem "dockerfile-rails", ">= 1.6", :group => :development

gem "aws-sdk-s3", "~> 1.169", :require => false

gem "kaminari", "~> 1.2"
