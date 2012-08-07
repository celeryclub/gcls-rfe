source :rubygems

ruby '1.9.3'

gem 'sinatra'
gem 'data_mapper'
gem 'thin'
gem 'sinatra-flash'
# gem 'rack-flash'
gem 'slim'
gem 'sass'
gem 'less'
gem 'therubyracer'
gem 'coffee-script'
# gem 'rdiscount'
gem 'rack-rewrite', :require => 'rack/rewrite'

group :production do
  gem 'pg'
  gem 'dm-postgres-adapter'
end

group :development do
  gem 'mysql2'
  gem 'dm-mysql-adapter'
end
