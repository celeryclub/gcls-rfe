require 'bundler'
Bundler.require

require './rfe'
run Sinatra::Application

require 'rack/rewrite'
use Rack::Rewrite do

  # Redirect from Heroku subdomain and add www
  r301 %r{.*}, "http://www.smartmoneygcls.org$&", :if => Proc.new { |rack_env| rack_env['SERVER_NAME'] == 'smartmoneygcls.herokuapp.com' || (!(rack_env['SERVER_NAME'] =~ /www\./i) && rack_env['SERVER_NAME'] != 'localhost') }

  # Strip trailing slashes
  r301 %r{^/(.*)/$}, '/$1'

end
