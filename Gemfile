source 'http://rubygems.org'

gem 'sinatra'
gem 'rack-flash3', :require => 'rack-flash'
gem 'data_mapper'
gem 'dm-rails', :require => 'dm-rails/mass_assignment_security'
gem 'warden'
gem 'bcrypt-ruby'
gem 'rspec'
gem 'rspec-core'
gem 'rack-test'

# is there a better alternative to filemagic?
# ruby-filemagic requires deb package libmagic-dev
gem 'ruby-filemagic'

group :development do
  gem 'dm-sqlite-adapter'
end
group :production do
  gem 'dm-postgres-adapter'
end


