require 'bundler'
Bundler.require

require './gvllib'
run Sinatra::Application

# require 'rack/rewrite'
# use Rack::Rewrite do

#   # Redirect from Heroku subdomain and add www
#   r301 %r{.*}, "http://www.stephendavis.im$&", :if => Proc.new { |rack_env| rack_env['SERVER_NAME'] == 'stephendavis.herokuapp.com' || (!(rack_env['SERVER_NAME'] =~ /www\./i) && rack_env['SERVER_NAME'] != 'localhost') }

#   # Strip trailing slashes
#   r301 %r{^/(.*)/$}, '/$1'

#   # WP and other misc
#   r301 %r{^/\?.*}, '/'
#   r301 %r{^/blog/category/.*}, '/blog/archive'
#   r301 %r{^/blog/author/.*}, '/blog/archive'
#   r301 %r{^/blog/(19|20)\d\d.*}, '/blog/archive'
#   r301 %r{^/page/.*}, '/blog'
#   # r301 %r{/users(.*)}, '/people$1'
#   r301 '/blog/new-album-released', '/blog/new-album-out'
#   r301 '/blog/font-face-text-shadow-and-google-chrome', '/blog/font-face-text-shadow-and-chrome'
#   r301 '/about-me', '/about'
#   r301 '/portfolio', '/projects'
#   r301 '/music', '/about'
#   r301 '/contact', '/about'
# end
