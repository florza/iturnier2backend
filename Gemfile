source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '2.7.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# 12.9.20, switch to 6.0.3.3 to close vulnerability GHSA-cfjv-5498-mph5
gem 'rails', '~> 6.0.3.3'
# Use Puma as the app server
gem 'puma', '~> 4.3.6'  # alt 3.7
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.2.2' # alt 4.1
gem 'jwt_sessions', '~> 2.5.2' # alt 2.3
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.16'  # alt 3.1.7

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

# for deployment to heroku,
# has been replaced by entries in config/environments/production.rb
# gem 'rails_12factor'

group :production do
  gem 'pg'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Use pry instead of irb because it has better functionality
  gem 'pry-rails'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Test coverage
  gem 'simplecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# GEMs for Graphity
# from https://www.graphiti.dev/guides/getting-started/installation

gem 'graphiti'
gem 'graphiti-rails'
gem 'responders'
gem 'vandal_ui'

# For automatic ActiveRecord pagination
gem 'kaminari'

# Test-specific gems
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'graphiti_spec_helpers'
end

# group :test do
#   gem 'database_cleaner'
# end
