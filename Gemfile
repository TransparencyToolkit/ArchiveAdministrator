source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'
gem 'rails', '~> 5.2.2.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.3'
gem 'resque'
gem 'curb'
gem 'crono'

# Authentication
gem 'devise'

# UI
gem 'jquery-rails'
gem 'underscore-rails'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

# undeclared dep for uglifier: pure ruby javascript interpreter:
gem 'therubyracer', '>= 0.12.3'


gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'bootsnap', '>= 1.1.0', require: false
gem 'turbolinks'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry'
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
