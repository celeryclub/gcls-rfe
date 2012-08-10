source :rubygems

ruby '1.9.3'

gem 'sinatra'
gem 'data_mapper'
gem 'thin'
gem 'sinatra-flash'
gem 'slim'
gem 'sass'
gem 'coffee-script'
gem 'rack-rewrite', :require => 'rack/rewrite'

group :production do
  gem 'pg'
  gem 'dm-postgres-adapter'
end

group :development do
  gem 'mysql'
  gem 'dm-mysql-adapter'
end
